require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:entity_type) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:invoice_prefix) }
    it { should validate_presence_of(:next_invoice_number) }
    it { should validate_numericality_of(:next_invoice_number).is_greater_than(0) }
    it { should validate_numericality_of(:default_payment_terms).is_greater_than_or_equal_to(0).allow_nil }

    it 'validates email format' do
      profile = Profile.new(email: 'invalid')
      expect(profile).not_to be_valid
      expect(profile.errors[:email]).to include('is invalid')
    end

    context 'when entity_type is business' do
      subject { Profile.new(entity_type: :business, email: 'test@example.com') }
      it { should validate_presence_of(:business_name) }
    end

    context 'when entity_type is individual' do
      subject { Profile.new(entity_type: :individual, email: 'test@example.com') }
      it { should validate_presence_of(:first_name) }
      it { should validate_presence_of(:last_name) }
    end
  end

  describe 'attachments' do
    it 'can attach a logo' do
      profile = create(:profile)
      expect(profile.logo).to be_an_instance_of(ActiveStorage::Attached::One)
    end

    it 'can attach a signature' do
      profile = create(:profile)
      expect(profile.signature).to be_an_instance_of(ActiveStorage::Attached::One)
    end
  end

  describe 'enums' do
    it { should define_enum_for(:entity_type).with_values(individual: 0, business: 1) }
  end

  describe '#display_name' do
    context 'when entity_type is business' do
      it 'returns the business name' do
        profile = Profile.new(entity_type: :business, business_name: 'Acme Corp', email: 'test@example.com')
        expect(profile.display_name).to eq('Acme Corp')
      end
    end

    context 'when entity_type is individual' do
      it 'returns the full name' do
        profile = Profile.new(entity_type: :individual, first_name: 'John', last_name: 'Doe', email: 'test@example.com')
        expect(profile.display_name).to eq('John Doe')
      end
    end
  end

  describe '#full_address' do
    it 'returns formatted multi-line address' do
      profile = Profile.new(
        email: 'test@example.com',
        address_line1: '123 Main St',
        address_line2: 'Suite 100',
        city: 'Austin',
        state: 'TX',
        zip_code: '78701',
        country: 'USA'
      )
      expected = "123 Main St\nSuite 100\nAustin, TX, 78701\nUSA"
      expect(profile.full_address).to eq(expected)
    end

    it 'handles missing address components' do
      profile = Profile.new(
        email: 'test@example.com',
        address_line1: '123 Main St',
        city: 'Austin',
        state: 'TX'
      )
      expected = "123 Main St\nAustin, TX\nUSA"
      expect(profile.full_address).to eq(expected)
    end
  end

  describe '#generate_next_invoice_number' do
    it 'generates an invoice number and increments the counter' do
      profile = Profile.create!(
        entity_type: :individual,
        first_name: 'John',
        last_name: 'Doe',
        email: 'john@example.com',
        invoice_prefix: 'INV',
        next_invoice_number: 1
      )

      invoice_number = profile.generate_next_invoice_number
      expect(invoice_number).to eq("INV-#{Date.current.year}-001")
      expect(profile.reload.next_invoice_number).to eq(2)
    end

    it 'pads the number with zeros' do
      profile = Profile.create!(
        entity_type: :individual,
        first_name: 'John',
        last_name: 'Doe',
        email: 'john@example.com',
        invoice_prefix: 'INV',
        next_invoice_number: 42
      )

      invoice_number = profile.generate_next_invoice_number
      expect(invoice_number).to eq("INV-#{Date.current.year}-042")
    end
  end
end
