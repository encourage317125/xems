'use strict';

angular.module('app.controllers', [])

# overall control
.controller('AppCtrl', [
    '$scope', '$location', 'sessionService'
    ($scope, $location, sessionService) ->

        init = ->
          if sessionService.authorized()
            $scope.currentUser = sessionService.getCurrentUser()

        $scope.isSpecificPage = ->
            path = $location.path()
            return _.contains( ['/404', '/500', '/login'], path )

        $scope.logout = ->
            sessionService.logout()
            .then((result)->
                $location.path '/login'
              ,
              (error)->
                alert('Error has been occured...')
              )

        init()
])

.controller('NavCtrl', [
    '$scope'
    ($scope) ->

])

.controller('DashboardCtrl', [
    '$scope'
    ($scope) ->

        $scope.comboChartData = [
            ['Month', 'Bolivia', 'Ecuador', 'Madagascar', 'Papua New Guinea', 'Rwanda', 'Average']
            ['2014/05',  165,      938,         522,             998,           450,      614.6]
            ['2014/06',  135,      1120,        599,             1268,          288,      682]
            ['2014/07',  157,      1167,        587,             807,           397,      623]
            ['2014/08',  139,      1110,        615,             968,           215,      609.4]
            ['2014/09',  136,      691,         629,             1026,          366,      569.6]
        ]

        $scope.salesData = [
            ['Year', 'Sales', 'Expenses']
            ['2010',  1000,      400]
            ['2011',  1170,      460]
            ['2012',  660,       1120]
            ['2013',  1030,      540]
        ]
])
