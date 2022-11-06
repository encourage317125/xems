class SuppliersController < ApplicationController
  respond_to :json

  def index
    @suppliers = Supplier.all
    respond_with @suppliers
  end

  def contacts
    supplier = Supplier.find(params[:id])
    @users = supplier.users
    respond_with @users
  end

  def create
    supplier = Supplier.new(create_parameters)
    if supplier.save
      render json: { supplier: supplier, done: true }
    else
      render json: { done: false }
    end
  end

  def update
    supplier = Supplier.find(params[:id])
    if supplier.update_attributes(update_parameters)
      render json: { supplier: supplier, done: true }
    else
      render json: { done: false }
    end
  end

  def destroy
    supplier = Supplier.find(params[:id])
    if supplier.destroy
      render json: { done: true }
    else
      render json: { done: false }
    end
  end

  private
    def create_parameters
      params.require(:supplier).permit!
    end
    def update_parameters
      params.require(:supplier).permit!
    end
end
