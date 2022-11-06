class ProjectTasksController < ApplicationController
  respond_to :json
  before_filter :load_project

  def index
    respond_with @project.project_tasks
  end

  def create
    task = @project.project_tasks.new(create_parameters)
    if task.save
      render json: { task: task, done: true }
    else
      render json: { done: false }
    end
  end

  def update
    task = @project.project_tasks.find(params[:id])
    if task.update_attributes(update_parameters)
      render json: { task: task, done: true }
    else
      render json: { done: false }
    end
  end

  def destroy
    task = @project.project_tasks.find(params[:id])
    if task.destroy
      render json: { done: true }
    else
      render json: { done: false }
    end
  end

  private
    def load_project
      @project = Project.find(params[:project_id])
    end
    def create_parameters
      params.require(:project_task).permit!
    end
    def update_parameters
      params.require(:project_task).permit!
    end
end
