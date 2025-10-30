class TimeEntriesController < ApplicationController
  before_action :set_time_entry, only: %i[show edit update destroy stop]
  before_action :set_select_collections, only: %i[new edit create update]

  def index
    sort_column = params[:sort] || 'created_at'
    sort_direction = params[:direction] || 'desc'

    time_entries = TimeEntry.includes(:client, :project)
                             .order("#{sort_column} #{sort_direction}")

    # Group by client, then by project
    @grouped_entries = time_entries.group_by(&:client).transform_values do |client_entries|
      client_entries.group_by(&:project)
    end

    # Calculate client totals
    @client_totals = {}
    @grouped_entries.each do |client, projects|
      total_earnings = 0
      total_duration = 0
      projects.each do |project, entries|
        entries.each do |entry|
          total_earnings += entry.earnings || 0
          total_duration += entry.duration_seconds || 0
        end
      end
      @client_totals[client.id] = {
        earnings: total_earnings,
        duration: total_duration,
        entries_count: projects.values.flatten.count
      }
    end
  end

  def new
    @time_entry = TimeEntry.new
    @running_time_entry = TimeEntry.running.first
  end

  def show; end

  def edit; end

  def create
    # Handle new client creation
    if params[:time_entry][:new_client_name].present?
      client = Client.find_or_create_by(name: params[:time_entry][:new_client_name])
      params[:time_entry][:client_id] = client.id
    end

    # Handle new project creation
    if params[:time_entry][:new_project_name].present?
      client_id = params[:time_entry][:client_id]
      if client_id.present?
        project = Project.find_or_create_by(
          name: params[:time_entry][:new_project_name],
          client_id: client_id
        ) do |p|
          p.rate = params[:time_entry][:new_project_rate] || 0
        end
        params[:time_entry][:project_id] = project.id
      end
    end

    # Handle existing task selection
    if params[:time_entry][:existing_task].present?
      params[:time_entry][:task] = params[:time_entry][:existing_task]
    end

    @time_entry = TimeEntry.new(time_entry_params)
    @time_entry.status = 'running'
    @time_entry.start_time = Time.current

    if @time_entry.save
      redirect_to root_path, notice: 'Timer started successfully.'
    else
      @running_time_entry = TimeEntry.running.first
      render :new, status: :unprocessable_content
    end
  end

  def update
    # If the time entry is paid, only allow updating notes
    if @time_entry.paid?
      allowed_params = params.require(:time_entry).permit(:notes)
      if @time_entry.update(allowed_params)
        redirect_to time_entries_path, notice: "Time entry notes were successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    else
      if @time_entry.update(time_entry_params)
        redirect_to time_entries_path, notice: "Time entry was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end
  end

  def destroy
    @time_entry.destroy
    redirect_to time_entries_path, notice: "Time entry was successfully destroyed."
  end

  def stop
    @time_entry.stop!
    redirect_to root_path, notice: 'Timer stopped successfully.'
  end

  private

  def set_time_entry
    @time_entry = TimeEntry.find(params[:id])
  end

  def set_select_collections
    @clients = Client.all
    @projects = Project.all
  end

  def time_entry_params
    params.require(:time_entry).permit(:task, :notes, :project_id, :client_id, :start_time, :end_time)
  end
end
