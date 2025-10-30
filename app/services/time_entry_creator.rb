class TimeEntryCreator
  def initialize(params)
    @params = params
  end

  def create
    find_or_create_client
    find_or_create_project
    handle_existing_task
    
    @time_entry = TimeEntry.new(@params.except(:new_client_name, :new_project_name, :new_project_rate, :existing_task))
    @time_entry.status = 'running'
    @time_entry.start_time = Time.current
    @time_entry.save
    @time_entry
  end

  private

  def find_or_create_client
    if @params[:new_client_name].present?
      client = Client.find_or_create_by(name: @params[:new_client_name])
      @params[:client_id] = client.id
    end
  end

  def find_or_create_project
    if @params[:new_project_name].present? && @params[:client_id].present?
      project = Project.find_or_create_by(
        name: @params[:new_project_name],
        client_id: @params[:client_id]
      ) do |p|
        p.rate = @params[:new_project_rate] || 0
      end
      @params[:project_id] = project.id
    end
  end

  def handle_existing_task
    if @params[:existing_task].present?
      @params[:task] = @params[:existing_task]
    end
  end
end
