class ProjectCustomersController < ApplicationController
  respond_to :json

  def create
    project_customer = ProjectCustomer.new(create_parameters)
    if project_customer.save
      render json: { customer: project_customer.customer, done: true }
    else
      render json: { done: false }
    end
  end

  def destroy
    project_customer = ProjectCustomer.where({project_id: params['project_id'], customer_id: params['customer_id']}).first
    if project_customer.destroy
      render json: { done: true }
    else
      render json: { done: false }
    end
  end
  private
    def create_parameters
      params.require(:project_customer).permit!
    end
    def update_parameters
      params.require(:project_customer).permit!
    end
end
