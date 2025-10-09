class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_running_timer

  private

  def set_running_timer
    @running_timer = TimeEntry.running.first
  end
end
