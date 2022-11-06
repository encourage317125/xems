'use strict'

angular.module('app.supplier', [])

.factory('supplierService', [
    '$resource'
    ($resource) ->
      service = $resource("/api/suppliers/:id.json", { id: "@id" },
      {
        'index':   { method: 'GET', isArray: true },
        'create':  { method: 'POST' },
        'update':  { method: 'PUT' },
        'destroy': { method: 'DELETE' }
      })
      contacts_service = $resource("/api/suppliers/:id/contacts.json", { id: "@id" },
      {
        'contacts':   { method: 'GET', isArray: true }
      })
      return {
        index: ->
          promise = service.index().$promise
          promise

        contacts: (supplier)->
          promise = contacts_service.contacts({id: supplier.id}).$promise
          promise

        create: (supplier)->
          promise = service.create({supplier: supplier}).$promise
          promise

        update: (supplier)->
          promise = service.update({id: supplier.id, supplier: supplier}).$promise
          promise

        destroy: (supplier)->
          promise = service.destroy({id: supplier.id}).$promise
          promise
        }
  ])

.controller('SupplierCtrl', [
    '$scope', 'supplierService', 'userService', 'logger'
    ($scope, supplierService, userService, logger) ->
        $scope.isNewSupplierCollapsed = true
        $scope.selectedSupplier = null
        $scope.isEditingSupplier = false
        $scope.isNewContact = false

        $scope.newSupplier =
          name: ''
          address: ''
          phone: ''
          website: ''
          email: ''

        original = angular.copy($scope.newSupplier)

        $scope.users = []
        $scope.newContact =
          name: ''
          email: ''
          role_id: 4
          customer_id: 0
          supplier_id: 0

        original_contact = angular.copy($scope.newContact)

        init = ->
          supplierService.index()
          .then((result)->
              $scope.suppliers = result
              $scope.selectedSupplier = $scope.suppliers[0]
            ,
            (error)->
              logger.logError("Error #{error}")
            )

        $scope.selectSupplier = (supplier)->
          $scope.selectedSupplier = supplier

        $scope.canSubmitSupplier = ->
          return $scope.form_supplier.$valid && !angular.equals($scope.newSupplier, original)

        $scope.revertSupplier = ->
          $scope.newSupplier = angular.copy(original)
          $scope.form_supplier.$setPristine()

        $scope.submitSupplier = ->
          supplierService.create($scope.newSupplier)
          .then((result)->
              if !!result.done
                $scope.suppliers.push(result.supplier)
                $scope.newSupplier  = []
                $scope.selectedSupplier = result.supplier
                $scope.revertSupplier()
                logger.logSuccess('New supplier: "' + result.supplier.name + '" created')
              else
                logger.logError('Transaction failed!')
            ,
            (error)->
              logger.logError("Error #{error}")
            )

        $scope.editSupplier = ()->
          $scope.isEditingSupplier = true

        $scope.doneSupplier = () ->
          supplierService.update($scope.selectedSupplier)
          .then((result)->
              if !!result.done
                $scope.isEditingSupplier = false
                logger.log('Supplier: "' + result.supplier.name + '" updated')
              else
                logger.logError('Transaction failed!')
            ,
            (error)->
              logger.logError("Error #{error}")
            )

        $scope.cancelEditingSupplier = ->
          $scope.isEditingSupplier = false

        $scope.removeSupplier = (supplier) ->
          supplierService.destroy(supplier)
          .then((result)->
              if !!result.done
                index = $scope.suppliers.indexOf(supplier)
                $scope.suppliers.splice(index, 1)
                $scope.selectedSupplier = $scope.suppliers[0]
                logger.log('Supplier: "' + supplier.name + '" removed')
              else
                logger.logError('Transaction failed!')
            ,
            (error)->
              logger.logError("Error #{error}")
            )

        $scope.getContacts = (supplier)->
          supplierService.contacts(supplier)
          .then((result)->
              $scope.users = result
            ,
            (error)->
              logger.logError("Error #{error}")
            )

        $scope.canSubmitContact = ->
          return $scope.form_contact.$valid && !angular.equals($scope.newContact, original_contact)

        $scope.revertContact = ->
          $scope.newContact = angular.copy(original_contact)
          $scope.form_contact.$setPristine()

        $scope.submitContact = ->
          $scope.newContact.supplier_id = $scope.selectedSupplier.id
          userService.create($scope.newContact)
          .then((result)->
              if !!result.done
                $scope.users.push(result.user)
                $scope.newContact = []
                $scope.revertContact()
                logger.logSuccess('New Contact: "' + result.user.name + '" created')
              else
                logger.logError('Transaction failed!')
            ,
            (error)->
              logger.logError("Error #{error}")
            )

        $scope.removeContact = (user)->
          userService.destroy(user)
          .then((result)->
              if !!result.done
                index = $scope.users.indexOf(user)
                $scope.users.splice(index, 1)
                logger.log('Contact: "' + user.name + '" removed')
              else
                logger.logError('Transaction failed!')
            ,
            (error)->
              logger.logError("Error #{error}")
            )

        $scope.$watch "selectedSupplier", (newValue, oldValue) ->
          if newValue == null
            return
          $scope.getContacts(newValue)
          return

        init()
])