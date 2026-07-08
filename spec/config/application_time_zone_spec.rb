require "rails_helper"

RSpec.describe "Application time zone" do
  it "uses Central Time for the app zone" do
    expect(Rails.application.config.time_zone).to eq("Central Time (US & Canada)")
  end
end
