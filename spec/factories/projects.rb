FactoryBot.define do
  factory :project do
    name { "Test Project" }
    rate { 100 }
    association :client
  end
end
