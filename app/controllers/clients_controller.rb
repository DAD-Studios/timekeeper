class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    @clients = Client.includes(:invoices).page(params[:page]).per(25)
  end

  def show
  end

  def new
    @client = Client.new
  end

  def edit
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to clients_url, notice: 'Client was successfully created.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @client.update(client_params)
      redirect_to clients_url, notice: 'Client was successfully updated.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    # Capture counts before deletion
    projects_count = @client.projects.count
    time_entries_count = @client.time_entries.count
    invoices_count = @client.invoices.count
    client_name = @client.name

    @client.destroy

    redirect_to clients_url,
      notice: "Client '#{client_name}' and all associated data were successfully deleted (#{projects_count} projects, #{time_entries_count} time entries, #{invoices_count} invoices)."
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :first_name, :last_name, :email, :phone, :address_line1, :address_line2,
                                   :city, :state, :zip_code, :country, :notes)
  end
end
