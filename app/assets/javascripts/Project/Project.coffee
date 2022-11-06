'use strict'

angular.module('app.project', [])
.factory('projectsService', [
    '$resource'
    ($resource) ->
      service = $resource("/api/projects/:id.json", { id: "@id" },
      {
        'index':   { method: 'GET', isArray: true },
        'create':  { method: 'POST' },
        'update':  { method: 'PUT' },
        'destroy': { method: 'DELETE' }
      })
      customers_service = $resource("/api/projects/:id/customers.json", { id: "@id" },
      {
        'customers': { method: 'GET', isArray: true }
      })
      users_service = $resource("/api/projects/:id/users.json", { id: "@id" },
      {
        'users': { method: 'GET', isArray: true }
      })
      return {
        index: ->
          promise = service.index().$promise
          promise

        customers: (project)->
          promise = customers_service.customers({id: project.id}).$promise
          promise

        users: (project)->
          promise = users_service.users({id: project.id}).$promise
          promise

        create: (project)->
          promise = service.create({project: project}).$promise
          promise

        update: (project)->
          promise = service.update({id: project.id, project: project}).$promise
          promise

        destroy: (project)->
          promise = service.destroy({id: project.id}).$promise
          promise
      }
])
.controller('ProjectNewCtrl', [
    '$scope', 'projectsService', 'logger'
    ($scope, projectsService, logger) ->
      $scope.newProject =
        name: ''
        startdate: new Date()
        enddate: new Date()
        category_id: 0

      original = angular.copy($scope.newProject)

      init = ->
        today = new Date()
        $scope.mindate = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate()

      $scope.canSubmitProject = ->
        return $scope.form_project.$valid && !angular.equals($scope.newProject, original)

      $scope.revertProject = ->
        $scope.newProject = angular.copy(original)
        $scope.form_project.$setPristine()
        $scope.$parent.selectedCategory = null

      $scope.submitProject = ->
        $scope.newProject.category_id = $scope.$parent.selectedCategory.id
        projectsService.create($scope.newProject)
        .then((result)->
            if !!result.done
              $scope.$parent.projects.push(result.project)
              $scope.newProject  = []
              $scope.revertProject()
              logger.logSuccess('New project: "' + result.project.name + '" created')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.cancelProject = ->
        $scope.$parent.selectedCategory = null

      init()
])
.controller('ProjectCtrl', [
    '$scope', 'projectsService', 'logger'
    ($scope, projectsService, logger) ->
      $scope.selectedProject = null
      $scope.isEditingProject = false
      $scope.arr_status = ['inactive', 'active', 'end']
      $scope.project_tabs = {'users': true, 'customers': false, 'tasks':false, 'files':false}
      $scope.statusFilter = ''

      init = ->
        projectsService.index()
        .then((result)->
            $scope.projects = result
            $scope.selectedProject = $scope.projects[0]
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.filter = (filter) ->
        switch filter
          when 'all' then $scope.statusFilter = ''
          when 'inactive' then $scope.statusFilter = {status: 0}
          when 'active' then $scope.statusFilter = {status: 1}
          when 'end' then $scope.statusFilter = {status: 2}

      $scope.selectProject = (project)->
        $scope.selectedProject = project

      $scope.editProject = ()->
        $scope.isEditingProject = true

      $scope.doneProject = () ->
        projectsService.update($scope.selectedProject)
        .then((result)->
            if !!result.done
              $scope.isEditingProject = false
              logger.log('Project: "' + result.project.name + '" updated')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.cancelEditingProject = ->
        $scope.isEditingProject = false

      $scope.removeProject = (project) ->
        projectsService.destroy(project)
        .then((result)->
            if !!result.done
              index = $scope.projects.indexOf(project)
              $scope.projects.splice(index, 1)
              $scope.selectedProject = $scope.projects[0]
              logger.log('Project: "' + project.name + '" removed')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.onClickTab = (tab) ->
        for key of $scope.project_tabs
          if key == tab
            $scope.project_tabs[key] = true
          else
            $scope.project_tabs[key] = false

      init()
])
.factory('project_customersService', [
    '$resource'
    ($resource) ->
      service = $resource("/api/project_customers/:id.json", {id: "@id"},
      {
        'create':  { method: 'POST' },
        'destroy': { method: 'DELETE' }
      })
      return {
        create: (project_customer)->
          promise = service.create({project_customer: project_customer}).$promise
          promise

        destroy: (project_id, customer_id)->
          promise = service.destroy({id: 0, project_id: project_id, customer_id: customer_id}).$promise
          promise
        }
])
.controller('ProjectCustomerCtrl', [
    '$scope', 'projectsService', 'project_customersService', 'customerService', 'logger'
    ($scope, projectsService, project_customersService, customerService, logger) ->

      $scope.newProjectCustomer =
        project_id: 0
        customer_id: 0

      init = ->
        customerService.index()
        .then((result)->
            $scope.allcustomers = result
            $scope.newProjectCustomer.customer_id = $scope.allcustomers[0].id
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.submitCustomer = ->
        project_customersService.create($scope.newProjectCustomer)
        .then((result)->
            if !!result.done
              $scope.customers.push(result.customer)
              logger.logSuccess('Customer: "' + result.customer.name + '" assigned')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.removeCustomer = (customer)->
        project_customersService.destroy($scope.$parent.selectedProject.id, customer.id)
        .then((result)->
            if !!result.done
              index = $scope.customers.indexOf(customer)
              $scope.customers.splice(index, 1)
              logger.log('Customer: "' + customer.name + '" removed')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.getCustomers = (project)->
        projectsService.customers(project)
        .then((result)->
            $scope.customers = result
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.$watch "$parent.selectedProject", (newValue, oldValue) ->
        if newValue == null
          return
        $scope.newProjectCustomer.project_id = newValue.id
        $scope.getCustomers(newValue)
        return

      init()
])
.factory('project_usersService', [
    '$resource'
    ($resource) ->
      service = $resource("/api/project_users/:id.json", {id: "@id"},
      {
        'create':  { method: 'POST' },
        'destroy': { method: 'DELETE' }
      })
      return {
        create: (project_user)->
          promise = service.create({project_user: project_user}).$promise
          promise

        destroy: (project_id, user_id)->
          promise = service.destroy({id: 0, project_id: project_id, user_id: user_id}).$promise
          promise
      }
])
.controller('ProjectUserCtrl', [
    '$scope', 'projectsService', 'project_usersService', 'userService', 'logger'
    ($scope, projectsService, project_usersService, userService, logger) ->
      $scope.newProjectUser =
        project_id: 0
        user_id: 0

      init = ->
        userService.users()
        .then((result)->
            $scope.allusers = result
            $scope.newProjectUser.user_id = $scope.allusers[0].id
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.submitUser = ->
        project_usersService.create($scope.newProjectUser)
        .then((result)->
            if !!result.done
              $scope.users.push(result.user)
              logger.logSuccess('User: "' + result.user.name + '" assigned')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.getUsers = (project)->
        projectsService.users(project)
        .then((result)->
            $scope.users = result
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.removeUser = (user)->
        project_usersService.destroy($scope.$parent.selectedProject.id, user.id)
        .then((result)->
            if !!result.done
              index = $scope.users.indexOf(user)
              $scope.users.splice(index, 1)
              logger.log('Customer: "' + user.name + '" removed')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.$watch "$parent.selectedProject", (newValue, oldValue) ->
        if newValue == null
          return
        $scope.newProjectUser.project_id = newValue.id
        $scope.getUsers(newValue)
        return
      init()
])

.factory('project_tasksService', [
    '$resource'
    ($resource) ->
      service = $resource("/api/projects/:project_id/project_tasks/:id.json", {project_id: "@project_id", id: "@id"},
      {
        'index':   { method: 'GET', isArray: true },
        'create':  { method: 'POST' },
        'update':  { method: 'PUT' },
        'destroy': { method: 'DELETE' }
      })
      return {
        index: (project)->
          promise = service.index({project_id: project.id}).$promise
          promise

        create: (task, project)->
          promise = service.create({project_id: project.id, project_task: task}).$promise
          promise

        update: (task, project)->
          promise = service.update({id: task.id, project_id: project.id, project_task: task}).$promise
          promise

        destroy: (task, project)->
          promise = service.destroy({id: task.id, project_id: project.id}).$promise
          promise
      }
])
.controller('ProjectTaskCtrl', [
    '$scope', 'projectsService', 'project_tasksService', 'logger'
    ($scope, projectsService, project_tasksService, logger) ->
      $scope.newTask =
        content: ''
        completed: false
        project_id: 0

      $scope.editedTask = null

      $scope.submitTask = ->
        project_tasksService.create($scope.newTask, $scope.$parent.selectedProject)
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
        project_tasksService.update(task, $scope.$parent.selectedProject)
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
        project_tasksService.destroy(task, $scope.$parent.selectedProject)
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
        project_tasksService.update(task, $scope.$parent.selectedProject)
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

      $scope.getTasks = (project)->
        project_tasksService.index(project)
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

      $scope.$watch "$parent.selectedProject", (newValue, oldValue) ->
        if newValue == null
          return
        $scope.newTask.project_id = newValue.id
        $scope.getTasks(newValue)
        return
])
.factory('project_filesService', [
    '$resource'
    ($resource) ->
      service = $resource("/api/projects/:project_id/project_files/:id.json", {project_id: "@project_id", id: "@id"},
      {
        'index':   { method: 'GET', isArray: true },
        'create':  { method: 'POST' },
        'destroy': { method: 'DELETE' }
      })
      return {
        index: (project)->
          promise = service.index({project_id: project.id}).$promise
          promise

        create: (file, project)->
          promise = service.create({project_id: project.id, project_file: file}).$promise
          promise

        destroy: (file, project)->
          promise = service.destroy({id: file.id, project_id: project.id}).$promise
          promise
      }
])
.controller('ProjectFileCtrl', [
  '$scope', 'projectsService', 'project_filesService', 'logger'
  ($scope, projectsService, project_filesService, logger) ->
    $scope.IsUploaded = false
    $scope.newFile =
      name: ''
      content_type: ''
      fileData: ''
      project_id: 0

    $scope.uploadFile = ->
      $scope.newFile.name = $scope.file.name
      $scope.newFile.content_type = $scope.file.type
      reader = new FileReader()
      reader.onload = (e) ->
        $scope.IsUploaded = true
        $scope.newFile.fileData = btoa(e.target.result)
        project_filesService.create($scope.newFile, $scope.$parent.selectedProject)
        .then((result)->
            if !!result.done
              $scope.IsUploaded = false
              $scope.files.push(result.file)
              $scope.file = null
              logger.logSuccess('File uploaded')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )
        return
      reader.readAsBinaryString($scope.file)

    $scope.removeFile = (file) ->
      project_filesService.destroy(file, $scope.$parent.selectedProject)
      .then((result)->
          if !!result.done
            index = $scope.files.indexOf(file)
            $scope.files.splice(index, 1)
            logger.log('File removed')
          else
            logger.logError('Transaction failed!')
        ,
        (error)->
          logger.logError("Error #{error}")
        )

    $scope.getFiles = (project)->
      project_filesService.index(project)
      .then((result)->
          $scope.files = result
        ,
        (error)->
          logger.logError("Error #{error}")
        )

    $scope.$watch "$parent.selectedProject", (newValue, oldValue) ->
      if newValue == null
        return
      $scope.newFile.project_id = newValue.id
      $scope.getFiles(newValue)
      return
]);