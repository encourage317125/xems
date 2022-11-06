'use strict';

angular.module('app', [
    # Angular modules
    'ngRoute'
    'ngResource'
    'ngCookies'
    'ngAnimate'

    # 3rd Party Modules
    'ui.bootstrap'
    'easypiechart'
    'mgo-angular-wizard'

    # Custom modules
    'app.controllers'
    'app.localization'
    'app.directives'
    'app.ui.services'
    'app.ui.form.directives'
    'app.login'
    'app.task'
    'app.user'
    'app.customer'
    'app.supplier'
    'app.project.category'
    'app.project'
    'app.plan.type'
    'app.plan'
])

.run ($rootScope, $location, sessionService) ->
    $rootScope.$on '$routeChangeStart', (event) ->
      if !sessionService.authorized()
        $location.path("/login")

.config([
    '$httpProvider', '$routeProvider'
    ($httpProvider, $routeProvider) ->
        $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = $("meta[name=\"csrf-token\"]").attr("content")

        $routeProvider
            .when(
                '/'
                redirectTo: '/dashboard'
            )
            .when(
                '/dashboard'
                templateUrl: 'assets/dashboard.html'
            )
            .when(
                '/login'
                templateUrl: 'assets/login.html'
            )
            .when(
                '/profile'
                templateUrl: 'assets/users/profile.html'
            )
            .when(
                '/users'
                templateUrl: 'assets/users/index.html'
            )
            .when(
                '/customers'
                templateUrl: 'assets/customers/index.html'
            )
            .when(
                '/suppliers'
                templateUrl: 'assets/suppliers/index.html'
            )
            .when(
                '/tasks'
                templateUrl: 'assets/tasks/index.html'
            )
            .when(
                '/projects'
                templateUrl: 'assets/projects/index.html'
            )
            .when(
                '/plans'
                templateUrl: 'assets/plans/plans.html'
            )
            .when(
                '/404'
                templateUrl: 'assets/errors/404.html'
            )
            .when(
                '/500'
                templateUrl: 'assets/errors/500.html'
            )
            .otherwise(
                redirectTo: '/login'
            )
])


