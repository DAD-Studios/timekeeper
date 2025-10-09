class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy]
  before_action :set_clients, only: %i[new edit create update]
  before_action :handle_new_client, only: %i[create update]

  DEFAULT_SORT_COLUMN = 'created_at'
  DEFAULT_SORT_DIRECTION = 'desc'

  def index
    projects = Project.includes(:client).order(sort_order)
    @grouped_projects = projects.group_by(&:client)
  end

  def show
    @time_entries = @project.time_entries.order(created_at: :desc).page(params[:page]).per(25)
  end

  def new
    @project = Project.new
  end

  def edit; end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to projects_url, notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      redirect_to projects_url, notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_url, notice: "Project was successfully destroyed."
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def set_clients
    @clients = Client.order(:name)
  end

  def handle_new_client
    return unless params[:project][:new_client_name].present?

    client = Client.find_or_create_by!(name: params[:project][:new_client_name])
    params[:project][:client_id] = client.id
  end

  def sort_order
    column = params[:sort].presence || DEFAULT_SORT_COLUMN
    direction = params[:direction].presence || DEFAULT_SORT_DIRECTION
    "#{column} #{direction}"
  end

  def project_params
    params.require(:project).permit(:name, :client_id, :rate)
  end
end
