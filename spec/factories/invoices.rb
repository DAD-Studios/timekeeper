FactoryBot.define do
  factory :invoice do
    association :client
    invoice_date { Date.current }
    due_date { Date.current + 30.days }
    status { :draft }

    after(:create) do |invoice|
      create(:invoice_line_item, invoice: invoice) if invoice.line_items.empty?
    end
  end

  factory :invoice_line_item do
    association :invoice
    description { "Web Development Services" }
    quantity { 40 }
    rate { 100.0 }
  end
end
