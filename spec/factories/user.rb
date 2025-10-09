FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    bio { Faker::Lorem.paragraph(sentence_count: 2) }
    address { Faker::Address.full_address }
    phone_number { Faker::PhoneNumber.phone_number_with_country_code }
    password { "password" }

    trait :admin do
      role { "admin" }
    end
  end
end