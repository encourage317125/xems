class PlantypesController < ApplicationController
  respond_to :json

  def index
    @plantypes = Plantype.all
    respond_with @plantypes
  end

  def create
    plantype = Plantype.new(create_parameters)
    if plantype.save
      render json: { plantype: plantype, done: true }
    else
      render json: { done: false }
    end
  end

  def update
    plantype = Plantype.find(params[:id])
    if plantype.update_attributes(update_parameters)
      render json: { plantype: plantype, done: true }
    else
      render json: { done: false }
    end
  end

  def destroy
    plantype = Plantype.find(params[:id])
    if plantype.destroy
      render json: { done: true }
    else
      render json: { done: false }
    end
  end

  private
    def create_parameters
      params.require(:plantype).permit!
    end
    def update_parameters
      params.require(:plantype).permit!
    end
end
