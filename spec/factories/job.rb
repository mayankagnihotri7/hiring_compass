FactoryBot.define do
  factory :job do
    title { "Software Engineer" }
    status { "open" }
    currency { "USD" }
    min_salary { 5000 }
    max_salary { 10000 }
    association :user
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    category { "sales" }
  end
end
