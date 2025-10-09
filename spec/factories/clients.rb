FactoryBot.define do
  factory :client do
    sequence(:name) { |n| "Client #{n}" }
    sequence(:email) { |n| "client#{n}@example.com" }
    phone { "(555) 123-4567" }
    address_line1 { "123 Main St" }
    city { "Austin" }
    state { "TX" }
    zip_code { "78701" }
  end
end
