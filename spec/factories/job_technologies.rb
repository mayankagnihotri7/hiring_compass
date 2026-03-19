FactoryBot.define do
  factory :job_technology do
    association :job
    association :technology
  end
end
