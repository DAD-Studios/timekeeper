class Api::ProjectsController < ApplicationController
  def index
    @projects = Project.where(client_id: params[:client_id])
    render json: @projects
  end
end
