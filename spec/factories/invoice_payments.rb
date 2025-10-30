FactoryBot.define do
  factory :invoice_payment do
    association :invoice
    amount { 100.0 }
    payment_date { Date.current }
    payment_method { :bank_wire }
  end
end