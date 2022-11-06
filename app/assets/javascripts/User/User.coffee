'use strict'

angular.module('app.user', [])

.factory('userService', [
    '$resource'
    ($resource) ->
      service = $resource("/api/users/:id.json", { id: "@id" },
      {
        'index':   { method: 'GET', isArray: true },
        'create':  { method: 'POST' },
        'update':  { method: 'PUT' },
        'destroy': { method: 'DELETE' }
      })
      users_service = $resource("/api/users/users.json", null,
      {
        'users':   { method: 'GET', isArray: true }
      })
      return {
        index: ->
          promise = service.index().$promise
          promise

        users: ->
          promise = users_service.users().$promise
          promise

        create: (user)->
          promise = service.create({user: user}).$promise
          promise

        update: (user)->
          delete user['photo']
          promise = service.update({id:user.id, user: user}).$promise
          promise

        destroy: (user)->
          promise = service.destroy({id: user.id}).$promise
          promise
      }
])
.controller('UserCtrl', [
    '$scope', 'userService', 'logger'
    ($scope, userService, logger) ->
      $scope.oneAtATime = true
      $scope.isNewUserCollapsed = true
      $scope.selectedUser = null

      $scope.newUser =
        name: ''
        email: ''
        role_id: 2
        customer_id: 0
        supplier_id: 0

      original = angular.copy($scope.newUser)

      init = ->
        userService.index()
        .then((result)->
            $scope.users = result
            $scope.selectedUser = $scope.users[0]
          ,
          (error)->
            logger.logError("Error #{error}")
          )
        $scope.roleFilter = {role_id: 1}

      $scope.filter = (filter) ->
        switch filter
          when 'administrators' then $scope.roleFilter = {role_id: 1}
          when 'users' then $scope.roleFilter = {role_id: 2}
          when 'staffs' then $scope.roleFilter = {role_id: 3}

      $scope.selectUser = (user) ->
        $scope.selectedUser = user

      $scope.canSubmitUser = ->
        return $scope.form_user.$valid && !angular.equals($scope.newUser, original)

      $scope.submitUser = ->
        userService.create($scope.newUser)
        .then((result)->
            if !!result.done
              $scope.users.push(result.user)
              $scope.selectedUser = result.user
              $scope.newUser = []
              $scope.revertUser()
              logger.logSuccess('New User: "' + result.user.name + '" created')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.revertUser = ->
        $scope.newUser = angular.copy(original)
        $scope.form_user.$setPristine()

      $scope.removeUser = (user) ->
        userService.destroy(user)
        .then((result)->
            if !!result.done
              index = $scope.users.indexOf(user)
              $scope.users.splice(index, 1)
              $scope.selectedUser = $scope.users[0]
              logger.log('User: "' + user.name + '" removed')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      init()
])

.controller('ProfileCtrl', [
    '$scope', 'userService', 'logger'
    ($scope, userService, logger) ->

      init = ->
        $scope.editMode = false
        $scope.editedUser = angular.copy($scope.currentUser)

      $scope.openFileWindow = ->
        document.getElementById('fileUpload').click()

      $scope.doneUser = ->
        userService.update($scope.editedUser)
        .then((result)->
            if !!result.done
              for k,v of result.user
                $scope.currentUser[k] = v
              logger.log('Profile has been updated!')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.$watch "photo", (newValue, oldValue) ->
        if typeof newValue is "undefined" || newValue == oldValue
          return
        $scope.currentUser.photo = "/assets/loading.gif"
        $scope.editedUser.imageContent = $scope.photo.type;
        $scope.editedUser.imagePath = $scope.photo.name;

        reader = new FileReader()
        reader.onload = (e) ->
          $scope.editedUser.imageData = btoa(e.target.result)
          userService.update($scope.editedUser)
          .then((result)->
              if !!result.done
                for k,v of result.user
                  $scope.currentUser[k] = v
                logger.log('Picture has been uploaded!')
              else
                logger.logError('Transaction failed!')
            ,
            (error)->
              logger.logError("Error #{error}")
            )
          return
        reader.readAsBinaryString($scope.photo)

      init()
])