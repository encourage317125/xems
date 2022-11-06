class PlancategoriesController < ApplicationController
  respond_to :json

  def index
    @plancategories = Plancategory.all
    respond_with @plancategories
  end

  def create
    plancategory = Plancategory.new(create_parameters)
    if plancategory.save
      render json: { plancategory: plancategory, done: true }
    else
      render json: { done: false }
    end
  end

  def update
    plancategory = Plancategory.find(params[:id])
    if plancategory.update_attributes(update_parameters)
      render json: { plancategory: plancategory, done: true }
    else
      render json: { done: false }
    end
  end

  def destroy
    plancategory = Plancategory.find(params[:id])
    if plancategory.destroy
      render json: { done: true }
    else
      render json: { done: false }
    end
  end

  private
    def create_parameters
      params.require(:plancategory).permit!
    end
    def update_parameters
      params.require(:plancategory).permit!
    end
end
