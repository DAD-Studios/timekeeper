FactoryBot.define do
  factory :profile do
    entity_type { :business }
    business_name { "Test Company" }
    email { "billing@example.com" }
    phone { "(555) 123-4567" }
    address_line1 { "123 Business St" }
    city { "Austin" }
    state { "TX" }
    zip_code { "78701" }
    invoice_prefix { "INV" }
    next_invoice_number { 1 }
    default_payment_terms { 30 }
  end
end
