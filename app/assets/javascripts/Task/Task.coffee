'use strict'

angular.module('app.task', [])

.factory('taskService', [
    '$resource'
    ($resource) ->
      service = $resource("/api/tasks/:id.json", { id: "@id" },
      {
        'index':   { method: 'GET', isArray: true },
        'create':  { method: 'POST' },
        'update':  { method: 'PUT' },
        'destroy': { method: 'DELETE' }
      })
      return {
        index: ()->
          promise = service.index().$promise
          promise

        create: (task)->
          promise = service.create({task: task}).$promise
          promise

        update: (task)->
          promise = service.update({id: task.id, task: task}).$promise
          promise

        destroy: (task)->
          promise = service.destroy({id: task.id}).$promise
          promise
      }
])

# cusor focus when dblclick to edit
.directive('taskFocus', [
    '$timeout'
    ($timeout) ->
        return {
            link: (scope, ele, attrs) ->
                scope.$watch(attrs.taskFocus, (newVal) ->
                    if newVal
                        $timeout( ->
                            ele[0].focus()
                        , 0, false)
                )
        }
])

.controller('TaskCtrl', [
    '$scope', 'taskService', 'logger'
    ($scope, taskService, logger) ->

        $scope.newTask =
            content: ''
            completed: false

        $scope.editedTask = null
        $scope.statusFilter = {completed: false}

        init = ->
          taskService.index()
          .then((result)->
              tasks = $scope.tasks = result
              count = 0
              for i in [0...tasks.length]
                 if !tasks[i].completed
                   count++
              $scope.remainingCount = count
            ,
            (error)->
              logger.logError("Error #{error}")
            )

        $scope.filter = (filter) ->
            switch filter
                when 'all' then $scope.statusFilter = ''
                when 'active' then $scope.statusFilter = {completed: false}
                when 'completed' then $scope.statusFilter = {completed: true}

        $scope.submitTask = ->
            taskService.create($scope.newTask)
            .then((result)->
                if !!result.done
                    $scope.tasks.push(result.task)
                    $scope.newTask.content = ''
                    $scope.remainingCount++
                    logger.logSuccess('New Task created')
                else
                  logger.logError('Transaction failed!')
              ,
              (error)->
                logger.logError("Error #{error}")
              )

        $scope.editTask = (task)->
            $scope.editedTask = task

        $scope.doneTask = (task) ->
            $scope.editedTask = null
            if task.content == ''
              return
            taskService.update(task)
            .then((result)->
                if !!result.done
                  logger.log('Task updated')
                else
                  logger.logError('Transaction failed!')
              ,
              (error)->
                logger.logError("Error #{error}")
              )

        $scope.removeTask = (task) ->
            $scope.remainingCount -= if task.completed then 0 else 1
            taskService.destroy(task)
            .then((result)->
                if !!result.done
                  index = $scope.tasks.indexOf(task)
                  $scope.tasks.splice(index, 1)
                  logger.log('Task removed')
                else
                  logger.logError('Transaction failed!')
              ,
              (error)->
                logger.logError("Error #{error}")
              )

        $scope.completedTask = (task) ->
            $scope.remainingCount += if task.completed then -1 else 1
            if !task.completed
              task.completed = false
            else
              task.completed = true
            taskService.update(task)
            .then((result)->
                if !!result.done
                  if task.completed
                    if $scope.remainingCount > 0
                      if $scope.remainingCount is 1
                        logger.log('Almost there! Only ' + $scope.remainingCount + ' task left')
                      else
                        logger.log('Good job! Only ' + $scope.remainingCount + ' tasks left')
                    else
                      logger.logSuccess('Congrats! All done :)')
                else
                  logger.logError('Transaction failed!')
              ,
              (error)->
                logger.logError("Error #{error}")
              )

        $scope.markAllTasks = (completed)->
            tasks = $scope.tasks
            tasks.forEach( (task) ->
                task.completed = completed
                taskService.update(task)
                .then((result)->
                    if !result.done
                      logger.logError('Transaction failed!')
                      return
                  ,
                  (error)->
                    logger.logError("Error #{error}")
                    return
                  )
            )
            $scope.remainingCount = if completed then 0 else tasks.length
            if completed
                logger.logSuccess('Congrats! All done :)')

        $scope.$watch('remainingCount == 0', (val) ->
            $scope.allChecked = val
        )

        init()
])