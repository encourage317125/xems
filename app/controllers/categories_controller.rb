class CategoriesController < ApplicationController
  respond_to :json

  def index
    @categories = Category.all
    respond_with @categories
  end

  def create
    category = Category.new(create_parameters)
    if category.save
      render json: { category: category, done: true }
    else
      render json: { done: false }
    end
  end

  def update
    category = Category.find(params[:id])
    if category.update_attributes(update_parameters)
      render json: { category: category, done: true }
    else
      render json: { done: false }
    end
  end

  def destroy
    category = Category.find(params[:id])
    if category.destroy
      render json: { done: true }
    else
      render json: { done: false }
    end
  end

  private
    def create_parameters
      params.require(:category).permit!
    end
    def update_parameters
      params.require(:category).permit!
    end
end
