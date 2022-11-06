'use strict'

angular.module('app.customer', [])

.factory('customerService', [
    '$resource'
    ($resource) ->
      service = $resource("/api/customers/:id.json", { id: "@id" },
      {
        'index':   { method: 'GET', isArray: true },
        'create':  { method: 'POST' },
        'update':  { method: 'PUT' },
        'destroy': { method: 'DELETE' }
      })
      contacts_service = $resource("/api/customers/:id/contacts.json", { id: "@id" },
      {
        'contacts':   { method: 'GET', isArray: true }
      })
      return {
        index: ->
          promise = service.index().$promise
          promise

        contacts: (customer)->
          promise = contacts_service.contacts({id: customer.id}).$promise
          promise

        create: (customer)->
          promise = service.create({customer: customer}).$promise
          promise

        update: (customer)->
          promise = service.update({id: customer.id, customer: customer}).$promise
          promise

        destroy: (customer)->
          promise = service.destroy({id: customer.id}).$promise
          promise
      }
])

.controller('CustomerCtrl', [
    '$scope', 'customerService', 'userService', 'logger'
    ($scope, customerService, userService, logger) ->
        $scope.isNewCustomerCollapsed = true
        $scope.selectedCustomer = null
        $scope.isEditingCustomer = false
        $scope.isNewContact = false

        $scope.newCustomer =
            name: ''
            address: ''
            phone: ''
            website: ''
            email: ''

        original = angular.copy($scope.newCustomer)

        $scope.users = []
        $scope.newContact =
            name: ''
            email: ''
            role_id: 4
            customer_id: 0
            supplier_id: 0

        original_contact = angular.copy($scope.newContact)

        init = ->
          customerService.index()
          .then((result)->
              $scope.customers = result
              $scope.selectedCustomer = $scope.customers[0]
            ,
            (error)->
              logger.logError("Error #{error}")
            )

        $scope.selectCustomer = (customer)->
          $scope.selectedCustomer = customer

        $scope.canSubmitCustomer = ->
          return $scope.form_customer.$valid && !angular.equals($scope.newCustomer, original)

        $scope.revertCustomer = ->
          $scope.newCustomer = angular.copy(original)
          $scope.form_customer.$setPristine()

        $scope.submitCustomer = ->
          customerService.create($scope.newCustomer)
          .then((result)->
              if !!result.done
                $scope.customers.push(result.customer)
                $scope.newCustomer  = []
                $scope.selectedCustomer = result.customer
                $scope.revertCustomer()
                logger.logSuccess('New customer: "' + result.customer.name + '" created')
              else
                logger.logError('Transaction failed!')
            ,
            (error)->
              logger.logError("Error #{error}")
            )

        $scope.editCustomer = ()->
          $scope.isEditingCustomer = true

        $scope.doneCustomer = () ->
          customerService.update($scope.selectedCustomer)
          .then((result)->
              if !!result.done
                $scope.isEditingCustomer = false
                logger.log('Customer: "' + result.customer.name + '" updated')
              else
                logger.logError('Transaction failed!')
            ,
            (error)->
              logger.logError("Error #{error}")
            )

        $scope.cancelEditingCustomer = ->
          $scope.isEditingCustomer = false

        $scope.removeCustomer = (customer) ->
          customerService.destroy(customer)
          .then((result)->
              if !!result.done
                index = $scope.customers.indexOf(customer)
                $scope.customers.splice(index, 1)
                $scope.selectedCustomer = $scope.customers[0]
                logger.log('Customer: "' + customer.name + '" removed')
              else
                logger.logError('Transaction failed!')
            ,
            (error)->
              logger.logError("Error #{error}")
            )

        $scope.getContacts = (customer)->
          customerService.contacts(customer)
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
          $scope.newContact.customer_id = $scope.selectedCustomer.id
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
                logger.log('User: "' + user.name + '" removed')
              else
                logger.logError('Transaction failed!')
            ,
            (error)->
              logger.logError("Error #{error}")
            )

        $scope.$watch "selectedCustomer", (newValue, oldValue) ->
            if newValue == null
                return
            $scope.getContacts(newValue)
            return

        init()
])