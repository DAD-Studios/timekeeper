module Api
  module V1
    class UnbilledTimeEntriesController < ApplicationController
      def index
        client = Client.find(params[:client_id])
        @time_entries = client.time_entries.unbilled.includes(:project)
        render json: {
          time_entries: @time_entries.map do |te|
            {
              id: te.id,
              task: te.task,
              project_name: te.project&.name,
              start_time: te.start_time&.strftime('%m/%d %I:%M%p'),
              end_time: te.end_time&.strftime('%I:%M%p'),
              duration_hours: te.duration_in_hours.round(2),
              rate: te.rate,
              earnings: te.earnings
            }
          end
        }
      end
    end
  end
end
