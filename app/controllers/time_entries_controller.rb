class TimeEntriesController < ApplicationController
  before_action :set_time_entry, only: %i[show edit update destroy stop]
  before_action :set_select_collections, only: %i[new edit create update]

  def index
    report = TimeEntryReport.new(sort_column: params[:sort], sort_direction: params[:direction]).generate
    @grouped_entries = report[:grouped_entries]
    @client_totals = report[:client_totals]
  end

  def new
    @time_entry = TimeEntry.new
    @running_time_entry = TimeEntry.running.first
  end

  def show; end

  def edit; end

  def create
    @time_entry = TimeEntryCreator.new(time_entry_params).create

    if @time_entry.persisted?
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
    params.require(:time_entry).permit(:task, :notes, :project_id, :client_id, :start_time, :end_time,
                                   :new_client_name, :new_project_name, :new_project_rate, :existing_task)
  end
end
