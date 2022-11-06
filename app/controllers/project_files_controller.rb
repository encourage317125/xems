class ProjectFilesController < ApplicationController
  respond_to :json
  before_filter :load_project

  def index
    respond_with @project.project_files
  end

  def create
    file = @project.project_files.new(create_parameters)
    file.url = "/files/"+file.name
    file.created_by = current_user.id
    if file.save
      decoded_data = Base64.decode64(params[:project_file][:fileData])
      ProjectFile.upload(file.name, decoded_data)
      render json: { file: file, done: true }
    else
      render json: { done: false }
    end
  end

  def destroy
    file = @project.project_files.find(params[:id])
    if file.destroy
      File.delete("#{Rails.root}/public/files/#{file.name}")
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
      params.require(:project_file).permit(:name, :content_type, :project_id)
    end
end
