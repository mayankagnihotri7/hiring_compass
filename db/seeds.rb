# frozen_string_literal: true

recruiters = 5.times.map do
  User.create!(
    email: Faker::Internet.unique.email,
    password: Faker::Internet.password,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    bio: Faker::Lorem.paragraph(sentence_count: 2),
    phone_number: "+91 1234567890"
  )
end

admin = User.create!(
  email: Faker::Internet.unique.email,
  password: "admin1",
  first_name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  bio: Faker::Lorem.paragraph(sentence_count: 2),
  role: "admin",
  phone_number: "+91 1234567890"
)

technologies = %w[
  Ruby Rails JavaScript React Python Django PostgreSQL MySQL Docker AWS Nodejs Typescript
  Vuejs Angular Go Rust Java Spring Boot MongoDB Redis Kubernetes GraphQL
]

# tech jobs
6.times do
  Jobs::SaveService.new(
    recruiters.sample,
    {
      title: Faker::Job.title,
      status: "open",
      currency: "USD",
      description: Faker::Lorem.paragraph(sentence_count: 3),
      category: "tech",
      min_salary: rand(60000..100000),
      max_salary: rand(100000..150000),
      years_of_experience: rand(1..6),
      technologies: technologies.sample(rand(2..4)).map { |name| { name: } }
    }
  ).call
end

# non tech jobs
6.times do
  Jobs::SaveService.new(
    recruiters.sample,
    {
      title: Faker::Job.title,
      status: "open",
      currency: "USD",
      description: Faker::Lorem.paragraph(sentence_count: 3),
      category: %w[sales marketing design product finance operations].sample,
      min_salary: rand(50000..80000),
      max_salary: rand(80000..120000),
      years_of_experience: rand(1..6)
    }
  ).call
end

puts "Seeded:\n#{User.count} users\n#{Technology.count} technologies\nand #{Job.count} jobs added"
