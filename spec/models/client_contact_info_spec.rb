require 'rails_helper'

RSpec.describe Client, type: :model do
  describe '#contact_name' do
    let(:client) { Client.new(name: 'Test Company') }

    context 'when both first_name and last_name are present' do
      it 'returns the full name' do
        client.first_name = 'John'
        client.last_name = 'Doe'
        expect(client.contact_name).to eq('John Doe')
      end
    end

    context 'when only first_name is present' do
      it 'returns the first name' do
        client.first_name = 'John'
        expect(client.contact_name).to eq('John')
      end
    end

    context 'when only last_name is present' do
      it 'returns the last name' do
        client.last_name = 'Doe'
        expect(client.contact_name).to eq('Doe')
      end
    end

    context 'when neither name is present' do
      it 'returns nil' do
        expect(client.contact_name).to be_nil
      end
    end
  end
end
