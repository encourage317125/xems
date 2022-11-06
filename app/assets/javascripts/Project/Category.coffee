'use strict'

angular.module('app.project.category', [])
.factory('categoriesService', [
    '$resource'
    ($resource) ->
      service = $resource("/api/categories/:id.json", { id: "@id" },
      {
        'index':   { method: 'GET', isArray: true },
        'create':  { method: 'POST' },
        'update':  { method: 'PUT' },
        'destroy': { method: 'DELETE' }
      })
      return {
        index: ->
          categories = service.index()
          categories

        create: (category)->
          promise = service.create({category: category}).$promise
          promise

        update: (category)->
          promise = service.update({id: category.id, category: category}).$promise
          promise

        destroy: (category)->
          promise = service.destroy({id: category.id}).$promise
          promise
      }
])

.controller('CategoryCtrl', [
    '$scope', 'categoriesService', 'logger'
    ($scope, categoriesService, logger)->
      $scope.isNewCategoryCollapsed = true
      $scope.categories = categoriesService.index()

      $scope.newCategory =
        title: ''

      original = angular.copy($scope.newCategory)

      $scope.editedCategory = null
      $scope.selectedCategory = null
      $scope.prevCategory = null

      $scope.selectCategory = (category)->
        $scope.selectedCategory = category

      $scope.canSubmitCategory = ->
        return $scope.form_category.$valid && !angular.equals($scope.newCategory, original)

      $scope.revertCategory = ->
        $scope.newCategory = angular.copy(original)
        $scope.form_category.$setPristine()

      $scope.submitCategory = ->
        categoriesService.create($scope.newCategory)
        .then((result)->
            if !!result.done
              $scope.categories.push(result.category)
              $scope.newCategory.category = []
              $scope.revertCategory()
              logger.logSuccess('New category: "' + result.category.title + '" created')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.editCategory = (category)->
        $scope.editedCategory = category
        $scope.prevCategory = angular.copy(category)

      $scope.doneCategory = (category) ->
        $scope.editedCategory = null
        if category.title == ''
          return;
        categoriesService.update(category)
        .then((result)->
            if !!result.done

              for i in [0...$scope.$parent.projects.length]
                if $scope.$parent.projects[i].category_id == result.category.id
                  $scope.$parent.projects[i].category = result.category.title

              logger.log('Category: "' + result.category.title + '" updated')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )

      $scope.cancelCategory = (category)->
        for k,v of $scope.prevCategory
          category[k] = v
        $scope.editedCategory = null

      $scope.removeCategory = (category) ->
        categoriesService.destroy(category)
        .then((result)->
            if !!result.done
              index = $scope.categories.indexOf(category)
              $scope.categories.splice(index, 1)
              logger.log('Category: "' + category.title + '" removed')
            else
              logger.logError('Transaction failed!')
          ,
          (error)->
            logger.logError("Error #{error}")
          )
])