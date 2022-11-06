'use strict'

angular.module('app.login', [])

.factory('sessionService', [
    '$resource', '$cookies'
    ($resource, $cookies)->
        service = $resource('/api/sessions/:id.json', {id: '@id'}, {
          show: { method: 'GET'}
          login: { method: 'POST' }
          logout: { method: 'DELETE' }
        })

        return {
            getCurrentUser: ->
              user = service.show({ id: $cookies.oauth_token })
              user

            authorized: ->
              $cookies.oauth_token != undefined

            login: (newUser)->
              promise = service.login(newUser).$promise
              promise

            logout: ->
              promise = service.logout({id: 1}).$promise
              promise
        }
])

.controller('LoginCtrl', [
    '$scope', '$location', '$cookies', 'sessionService', 'logger'
    ($scope, $location, $cookies, sessionService, logger) ->

        $scope.user =
            email: ''
            password: ''

        original = angular.copy($scope.user)

        $scope.canSubmit = ->
          return $scope.form_login.$valid && !angular.equals($scope.user, original)

        $scope.submit = ->
          sessionService.login($scope.user)
          .then((result)->
              if !!result.authorized
                $cookies.oauth_token = result.user.oauth_token
                location.href = '/'
              else
                logger.logError('Invalid username or password!');
            ,
            (error)->
              logger.logError("Error #{error}");
            )
])