require 'rails_helper'

RSpec.describe Project, type: :model do
  it { should belong_to(:client) }
  it { should have_many(:time_entries).dependent(:destroy) }

  it { should validate_presence_of(:name) }
  it { should validate_numericality_of(:rate).is_greater_than_or_equal_to(0) }

  describe 'validations' do
    let(:client) { create(:client) }
    before { create(:project, client: client) }
    it { should validate_uniqueness_of(:name).scoped_to(:client_id).case_insensitive }
  end
end
