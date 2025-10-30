class TimeEntryReport
  def initialize(sort_column: 'created_at', sort_direction: 'desc')
    @sort_column = sort_column
    @sort_direction = sort_direction
  end

  def generate
    time_entries = TimeEntry.includes(:client, :project)
                             .order("#{@sort_column} #{@sort_direction}")

    grouped_entries = time_entries.group_by(&:client).transform_values do |client_entries|
      client_entries.group_by(&:project)
    end

    client_totals = calculate_client_totals(grouped_entries)

    { grouped_entries: grouped_entries, client_totals: client_totals }
  end

  private

  def calculate_client_totals(grouped_entries)
    client_totals = {}
    grouped_entries.each do |client, projects|
      total_earnings = 0
      total_duration = 0
      projects.each do |project, entries|
        entries.each do |entry|
          total_earnings += entry.earnings || 0
          total_duration += entry.duration_seconds || 0
        end
      end
      client_totals[client.id] = {
        earnings: total_earnings,
        duration: total_duration,
        entries_count: projects.values.flatten.count
      }
    end
    client_totals
  end
end
