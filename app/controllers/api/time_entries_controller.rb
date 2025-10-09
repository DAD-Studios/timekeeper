class Api::TimeEntriesController < ApplicationController
  def tasks
    @time_entries = TimeEntry.select(:task, :client_id, :project_id).distinct
    render json: @time_entries
  end
end
