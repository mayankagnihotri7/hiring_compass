FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    bio { Faker::Lorem.paragraph(sentence_count: 2) }
    address { Faker::Address.full_address }
    phone_number { "+91; 1234567890" }
    password { "password" }
    confirmed_at { DateTime.now }

    trait :admin do
      role { "admin" }
    end

    trait :not_confirmed do
      confirmed_at { nil }
    end
  end
end