FactoryBot.define do
  factory :technology do
    name { Faker::Lorem.word.capitalize }
  end
end
