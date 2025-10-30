class ProfilesController < ApplicationController
  def edit
    @profile = Profile.first_or_initialize
  end

  def update
    @profile = Profile.first_or_initialize

    if @profile.update(profile_params)
      redirect_to edit_profile_path, notice: 'Profile was successfully updated.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def profile_params
    params.require(:profile).permit(
      :entity_type, :first_name, :last_name, :title, :business_name, :tax_id,
      :email, :phone, :website, :address_line1, :address_line2, :city, :state,
      :zip_code, :country, :invoice_prefix, :next_invoice_number,
      :default_payment_terms, :default_invoice_notes, :default_payment_instructions,
      :primary_color, :show_logo, :logo, :signature
    )
  end
end
