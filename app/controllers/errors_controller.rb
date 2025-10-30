class ErrorsController < ApplicationController
  layout 'application'

  def not_found
    @exception = request.env['action_dispatch.exception']
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { error: 'Not found' }, status: :not_found }
    end
  end

  def internal_server_error
    @exception = request.env['action_dispatch.exception']
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.json { render json: { error: 'Internal server error' }, status: :internal_server_error }
    end
  end

  def unprocessable_content
    @exception = request.env['action_dispatch.exception']
    respond_to do |format|
      format.html { render status: :unprocessable_content }
      format.json { render json: { error: 'Unprocessable entity' }, status: :unprocessable_content }
    end
  end
end