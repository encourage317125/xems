class TasksController < ApplicationController
  respond_to :json

  def index
    @tasks = Task.find_all_by_user_id(current_user.id)
    respond_with @tasks
  end

  def create
    task = Task.new(create_parameters)
    task.user_id = current_user.id
    if task.save
      render json: { task: task, done: true }
    else
      render json: { done: false }
    end
  end

  def update
    task = Task.find(params[:id])
    if task.update_attributes(update_parameters)
      render json: { task: task, done: true }
    else
      render json: { done: false }
    end
  end

  def destroy
    task = Task.find(params[:id])
    if task.destroy
      render json: { done: true }
    else
      render json: { done: false }
    end
  end

  private
    def create_parameters
      params.require(:task).permit!
    end
    def update_parameters
      params.require(:task).permit!
    end
end
