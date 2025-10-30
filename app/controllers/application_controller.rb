class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_running_timer

  # Error handling - only in production
  unless Rails.env.development?
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::RoutingError, with: :render_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
    rescue_from StandardError, with: :render_internal_server_error
  end

  private

  def set_running_timer
    @running_timer = TimeEntry.running.first
  end

  def render_not_found(exception = nil)
    @exception = exception
    logger.error "404 Not Found: #{exception.message}" if exception

    respond_to do |format|
      format.html { render 'errors/not_found', status: :not_found, layout: 'application' }
      format.json { render json: { error: 'Not found', message: exception&.message }, status: :not_found }
      format.all { render body: nil, status: :not_found }
    end
  end

  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_content

  # Other code

  private

  def render_unprocessable_content(exception = nil)
    @exception = exception
    respond_to do |format|
      format.html { render 'errors/unprocessable_content', status: :unprocessable_content, layout: 'application' }
      format.json { render json: { error: exception&.message }, status: :unprocessable_content }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          dom_id(exception.record),
          partial: 'shared/form_errors',
          locals: { resource: exception.record }
        ), status: :unprocessable_content
      end
    end
  end

  def render_internal_server_error(exception = nil)
    @exception = exception
    logger.error "500 Internal Server Error: #{exception.message}" if exception
    logger.error exception.backtrace.join("\n") if exception&.backtrace

    respond_to do |format|
      format.html { render 'errors/internal_server_error', status: :internal_server_error, layout: 'application' }
      format.json { render json: { error: 'Internal server error' }, status: :internal_server_error }
      format.all { render body: nil, status: :internal_server_error }
    end
  end
end
