require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'associations' do
    it { should have_many(:projects).dependent(:destroy) }
    it { should have_many(:time_entries).dependent(:destroy) }
    it { should have_many(:invoices).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }

    it 'validates email format when present' do
      client = Client.new(name: 'Test Client', email: 'invalid')
      expect(client).not_to be_valid
      expect(client.errors[:email]).to include('is invalid')
    end

    it 'allows blank email' do
      client = Client.new(name: 'Test Client', email: '')
      expect(client).to be_valid
    end
  end

  describe '#full_address' do
    it 'returns formatted multi-line address' do
      client = Client.new(
        name: 'Test Client',
        address_line1: '456 Client Ave',
        address_line2: 'Floor 2',
        city: 'Dallas',
        state: 'TX',
        zip_code: '75201',
        country: 'USA'
      )
      expected = "456 Client Ave\nFloor 2\nDallas, TX, 75201\nUSA"
      expect(client.full_address).to eq(expected)
    end

    it 'handles missing address components' do
      client = Client.new(
        name: 'Test Client',
        address_line1: '456 Client Ave',
        city: 'Dallas'
      )
      expected = "456 Client Ave\nDallas\nUSA"
      expect(client.full_address).to eq(expected)
    end
  end
end
