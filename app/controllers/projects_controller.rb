class ProjectsController < ApplicationController
  respond_to :json

  def index
    @projects = Project.find_all_by_created_by(current_user.id)
    respond_with @projects
  end

  def customers
    project = Project.find(params[:id])
    respond_with project.customers
  end

  def users
    project = Project.find(params[:id])
    @users = project.users
    respond_with @users
  end

  def create
    project = Project.new(create_parameters)
    project.created_by = current_user.id
    if project.save
      render json: { project: {id: project.id, name: project.name, startdate: project.startdate, enddate: project.enddate, status: project.status, category_id: project.category_id, category: project.category.title}, done: true }
    else
      render json: { done: false }
    end
  end

  def update
    project = Project.find(params[:id])
    if project.update_attributes(update_parameters)
      render json: { project: {id: project.id, name: project.name, startdate: project.startdate, enddate: project.enddate, status: project.status, category_id: project.category_id, category: project.category.title}, done: true }
    else
      render json: { done: false }
    end
  end

  def destroy
    project = Project.find(params[:id])
    if project.destroy
      render json: { done: true }
    else
      render json: { done: false }
    end
  end
  private
    def create_parameters
      params.require(:project).permit(:name, :startdate, :enddate, :category_id)
    end
    def update_parameters
      params.require(:project).permit(:name, :startdate, :enddate, :category_id)
    end
end
