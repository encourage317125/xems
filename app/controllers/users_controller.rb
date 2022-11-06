class UsersController < ApplicationController
  respond_to :json
  before_action :update_parameters, only: [:update]

  def index
    @users = User.find_all_by_role_id([1, 2, 3])
    respond_with @users
  end

  def users
    @users = User.find_all_by_role_id(2)
    respond_with @users
  end

  def create
    user = User.new(create_parameters)
    user.password = password_generate 8
    if user.save
      info = {name: user.name,
              email: user.email,
              subject: "New Account on XEMS",
              message: "You have an Account on XEMS now. Password: #{user.password}"
            }
      #Notifier.send_email(info).deliver
      render json: { user: {id: user.id, name: user.name, email: user.email, address: user.address, phone: user.phone, thumb: user.photo.url(:thumb), role_id: user.role_id, customer_id: user.customer_id, supplier_id: user.supplier_id}, done: true }
    else
      render json: { done: false }
    end
  end

  def update
    user = User.find(params[:id])
    if params[:user][:imageData]
      decode_image
    end
    if user.update_attributes(@up)
      render json: { user: {id: user.id, name: user.name, email: user.email, address: user.address, phone: user.phone, photo: user.photo.url, thumb: user.photo.url(:thumb)}, done: true }
    else
      render json: { done: false }
    end
  end

  def destroy
    user = User.find(params[:id])
    if user.destroy
      render json: { done: true }
    else
      render json: { done: false }
    end
  end
  private
    def create_parameters
      params.require(:user).permit(:name, :email, :role_id, :customer_id, :supplier_id)
    end
    def update_parameters
      @up = params.require(:user).permit(:name, :address, :photo, :phone, :password)
    end
    def decode_image
      decoded_data = Base64.decode64(params[:user][:imageData])
      data = StringIO.new(decoded_data)
      data.class_eval do
        attr_accessor :content_type, :original_filename
      end

      data.content_type = params[:user][:imageContent]
      data.original_filename = params[:user][:imagePath]
      @up[:photo] = data
    end
end
