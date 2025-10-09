FactoryBot.define do
  factory :job do
    title { "Software Engineer" }
    status { "open" }
    currency { "USD" }
    min_salary { 5000 }
    max_salary { 10000 }
    association :user
  end
end
