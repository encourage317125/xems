class ProjectUsersController < ApplicationController
  respond_to :json

  def create
    project_user = ProjectUser.new(create_parameters)
    if project_user.save
      render json: { user: {id: project_user.user.id, name: project_user.user.name, email: project_user.user.email, address: project_user.user.address, phone: project_user.user.phone, thumb: project_user.user.photo.url(:thumb), role_id: project_user.user.role_id, customer_id: project_user.user.customer_id, supplier_id: project_user.user.supplier_id}, done: true }
    else
      render json: { done: false }
    end
  end

  def destroy
    project_user = ProjectUser.where({project_id: params['project_id'], user_id: params['user_id']}).first
    if project_user.destroy
      render json: { done: true }
    else
      render json: { done: false }
    end
  end

  private
    def create_parameters
      params.require(:project_user).permit!
    end
    def update_parameters
      params.require(:project_user).permit!
    end
end
