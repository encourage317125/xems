'use strict'

angular.module('app.plan.type', [])

.factory('plancategoriesService', [
    '$resource'
    ($resource) ->
      service = $resource("/api/plancategories/:id.json", { id: "@id" },
      {
        'index':   { method: 'GET', isArray: true },
        'create':  { method: 'POST' },
        'update':  { method: 'PUT' },
        'destroy': { method: 'DELETE' }
      })
      return {
        index: ->
          plancategories = service.index()
          plancategories

        create: (plancategory)->
          promise = service.create({plancategory: plancategory}).$promise
          promise

        update: (plancategory)->
          promise = service.update({id: plancategory.id ,plancategory: plancategory}).$promise
          promise

        destroy: (plancategory)->
          promise = service.destroy({id: plancategory.id}).$promise
          promise
      }
  ])

.factory('plantypesService', [
    '$resource'
    ($resource) ->
      service = $resource("/api/plantypes/:id.json", { id: "@id" },
      {
        'index':   { method: 'GET', isArray: true },
        'create':  { method: 'POST' },
        'update':  { method: 'PUT' },
        'destroy': { method: 'DELETE' }
      })
      return {
        index: ->
          plantypes = service.index()
          plantypes

        create: (plantype)->
          promise = service.create({plantype: plantype}).$promise
          promise

        update: (plantype)->
          promise = service.update({id: plantype.id, plantype: plantype}).$promise
          promise

        destroy: (plantype)->
          promise = service.destroy({id: plantype.id}).$promise
          promise
      }
  ])

.controller('PlanTypeCtrl', [
    '$scope', 'plancategoriesService', 'plantypesService', 'logger'
    ($scope, plancategoriesService, plantypesService, logger)->
      $scope.isNewPlancategoryCollapsed = true
      $scope.plancategories = plancategoriesService.index()
      $scope.selectedPlancategory = null
      $scope.editedPlancategory = null
      $scope.prevPlancategory = null

      $scope.newPlancategory =
        title: ''

      original = angular.copy($scope.newPlancategory)

      $scope.isNewPlantypeCollapsed = true
      $scope.plantypes = plantypesService.index()
      $scope.editedPlantype = null
      $scope.prevPlantype = null

      $scope.newPlantype =
        name: ''
        price: 0.00
        minprice: 0.00
        vat: 0.00
        plancategory_id: 0

      original_plantype = angular.copy($scope.newPlantype)

      $scope.selectPlancategory = (plancategory)->
        $scope.selectedPlancategory = plancategory

      $scope.submitPlancategory = ->
        plancategoriesService.create($scope.newPlancategory)
        .then((result)->
            if !!result.done
              $scope.plancategories.push(result.plancategory)
              $scope.newPlancategory = []
              $scope.revertPlancategory()
              logger.logSuccess('New category: "' + result.plancategory.title + '" created')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.revertPlancategory = ->
        $scope.newPlancategory = angular.copy(original)
        $scope.form_category.$setPristine()

      $scope.canSubmitPlancategory = ->
        return $scope.form_category.$valid && !angular.equals($scope.newPlancategory, original)

      $scope.editPlancategory = (plancategory)->
        $scope.editedPlancategory = plancategory
        $scope.prevPlancategory = angular.copy(plancategory)

      $scope.donePlancategory = (plancategory) ->
        $scope.editedPlancategory = null
        if plancategory.title == ''
          return
        plancategoriesService.update(plancategory)
        .then((result)->
            if !!result.done
              logger.log('Category: "' + result.plancategory.title + '" updated')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.cancelPlancategory = (plancategory)->
        for k,v of $scope.prevPlancategory
          plancategory[k] = v
        $scope.editedPlancategory = null

      $scope.removePlancategory = (plancategory) ->
        plancategoriesService.destroy(plancategory)
        .then((result)->
            if !!result.done
              index = $scope.plancategories.indexOf(plancategory)
              $scope.plancategories.splice(index, 1)
              logger.log('Category: "' + plancategory.title + '" removed')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.canSubmitType = ->
        return $scope.form_type.$valid && !angular.equals($scope.newPlantype, original_plantype)

      $scope.submitType = ->
        $scope.newPlantype.plancategory_id = $scope.selectedPlancategory.id
        plantypesService.create($scope.newPlantype)
        .then((result)->
            if !!result.done
              $scope.plantypes.push(result.plantype)
              $scope.newPlantype = []
              $scope.revertType()
              logger.logSuccess('New Type: "' + result.plantype.name + '" created')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.revertType = ->
        $scope.newPlantype = angular.copy(original_plantype)
        $scope.form_type.$setPristine()
        $scope.selectedPlancategory = null

      $scope.editType = (plantype)->
        $scope.editedPlantype = plantype
        $scope.prevPlantype = angular.copy(plantype)

      $scope.cancelType = (plantype)->
        for k,v of $scope.prevPlantype
          plantype[k] = v
        $scope.editedPlantype = null

      $scope.removeType = (plantype) ->
        plantypesService.destroy(plantype)
        .then((result)->
            if !!result.done
              index = $scope.plantypes.indexOf(plantype)
              $scope.plantypes.splice(index, 1)
              logger.log('Type: "' + plantype.name + '" removed')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.doneType = (plantype) ->
        $scope.editedPlantype = null
        if plantype.title == ''
          return
        plantypesService.update(plantype)
        .then((result)->
            if !!result.done
              logger.log('Type: "' + result.plantype.name + '" updated')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )
])