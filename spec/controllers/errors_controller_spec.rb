require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  describe 'GET #not_found' do
    it 'returns a 404 status' do
      get :not_found
      expect(response).to have_http_status(:not_found)
    end

    it 'renders the not_found template' do
      get :not_found
      expect(response).to render_template(:not_found)
    end

    it 'uses the application layout' do
      get :not_found
      expect(response).to render_template(layout: 'application')
    end

    context 'with JSON format' do
      it 'returns JSON error response' do
        get :not_found, format: :json
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include('error' => 'Not found')
      end
    end

    context 'with exception in request environment' do
      before do
        exception = ActiveRecord::RecordNotFound.new('Record not found')
        request.env['action_dispatch.exception'] = exception
      end

      it 'assigns the exception to @exception' do
        get :not_found
        expect(assigns(:exception)).to be_a(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET #internal_server_error' do
    it 'returns a 500 status' do
      get :internal_server_error
      expect(response).to have_http_status(:internal_server_error)
    end

    it 'renders the internal_server_error template' do
      get :internal_server_error
      expect(response).to render_template(:internal_server_error)
    end

    it 'uses the application layout' do
      get :internal_server_error
      expect(response).to render_template(layout: 'application')
    end

    context 'with JSON format' do
      it 'returns JSON error response' do
        get :internal_server_error, format: :json
        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)).to include('error' => 'Internal server error')
      end
    end

    context 'with exception in request environment' do
      before do
        exception = StandardError.new('Something went wrong')
        request.env['action_dispatch.exception'] = exception
      end

      it 'assigns the exception to @exception' do
        get :internal_server_error
        expect(assigns(:exception)).to be_a(StandardError)
      end
    end
  end

  describe 'GET #unprocessable_content' do
    it 'returns a 422 status' do
      get :unprocessable_content
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'renders the unprocessable_content template' do
      get :unprocessable_content
      expect(response).to render_template(:unprocessable_content)
    end

    it 'uses the application layout' do
      get :unprocessable_content
      expect(response).to render_template(layout: 'application')
    end

    context 'with JSON format' do
      it 'returns JSON error response' do
        get :unprocessable_content, format: :json
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)).to include('error' => 'Unprocessable entity')
      end
    end

    context 'with exception in request environment' do
      before do
        exception = ActiveRecord::RecordInvalid.new
        request.env['action_dispatch.exception'] = exception
      end

      it 'assigns the exception to @exception' do
        get :unprocessable_content
        expect(assigns(:exception)).to be_a(ActiveRecord::RecordInvalid)
      end
    end
  end
end
