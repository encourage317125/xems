class CustomersController < ApplicationController
  respond_to :json

  def index
    @customers = Customer.all
    respond_with @customers
  end

  def contacts
    customer = Customer.find(params[:id])
    @users = customer.users
    respond_with @users
  end

  def create
    customer = Customer.new(create_parameters)
    if customer.save
      render json: { customer: customer, done: true }
    else
      render json: { done: false }
    end
  end

  def update
    customer = Customer.find(params[:id])
    if customer.update_attributes(update_parameters)
      render json: { customer: customer, done: true }
    else
      render json: { done: false }
    end
  end

  def destroy
    customer = Customer.find(params[:id])
    if customer.destroy
      render json: { done: true }
    else
      render json: { done: false }
    end
  end
  private
    def create_parameters
      params.require(:customer).permit!
    end
    def update_parameters
      params.require(:customer).permit!
    end
end
