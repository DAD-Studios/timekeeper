class ReportsController < ApplicationController
  def index
    @selected_date = params[:selected_date] ? Date.parse(params[:selected_date]) : Date.current
    @current_month = params[:month] ? Date.parse(params[:month]) : Date.current.beginning_of_month

    # Get all time entries for the current month for calendar display
    month_entries = TimeEntry.where(start_time: @current_month.all_month).includes(:project, :client)

    # Calculate day metrics for calendar
    @day_metrics = {}
    month_entries.group_by { |t| t.start_time.to_date }.each do |date, entries|
      projects = entries.map(&:project).uniq
      @day_metrics[date] = {
        projects_count: projects.count,
        tasks_count: entries.count,
        earnings: entries.sum { |e| e.earnings || 0 }
      }
    end

    # Get entries for selected day
    @selected_entries = TimeEntry.where(start_time: @selected_date.all_day)
                                  .includes(:project, :client)
                                  .order(:start_time)

    # Group entries by client and project
    @grouped_entries = @selected_entries.group_by(&:client).transform_values do |client_entries|
      client_entries.group_by(&:project)
    end

    @selected_total_duration = @selected_entries.sum { |e| e.duration_seconds || 0 }
    @selected_total_earnings = @selected_entries.sum { |e| e.earnings || 0 }
  end
end
