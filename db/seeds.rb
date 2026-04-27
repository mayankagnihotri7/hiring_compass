# frozen_string_literal: true

countries = %w[US GB IN HK CN]

ActiveRecord::Base.transaction do
  recruiters = 5.times.map do
    User.create!(
      email: "user_#{SecureRandom.hex(4)}@example.com",
      password: Faker::Internet.password,
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      bio: Faker::Lorem.paragraph(sentence_count: 2),
      phone_number: [
        "+1; 555 123 4567",
        "+44; 20 7946 0858",
        "+91; 98765 43210",
        "+852; 9123 4567",
        "+86; 138 0013 8000"
      ].sample
    )
  end

  admin = User.create!(
    email: "user_#{SecureRandom.hex(4)}@example.com",
    password: "admin1",
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    bio: Faker::Lorem.paragraph(sentence_count: 2),
    role: "admin",
    phone_number: [
      "+1; 555 123 4567",
      "+44; 20 7946 0858",
      "+91; 98765 43210",
      "+852; 9123 4567",
      "+86; 138 0013 8000"
    ].sample
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
        company_name: Faker::Company.name,
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
        company_name: Faker::Company.name,
        years_of_experience: rand(1..6)
      }
    ).call
  end

  # JobApplication
  file_path = Rails.root.join("tmp", "storage", "resume.pdf")
  Job.find_each do |job|
    job_app = job.job_applications.new(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      years_of_experience: rand(0..job.years_of_experience + 2),
      email: Faker::Internet.unique.email,
      phone_number: Faker::PhoneNumber.phone_number
    )
    job_app.resume.attach(
      io: File.open(file_path),
      filename: "resume.pdf",
      content_type: "application/pdf"
    )
    job_app.save!

    puts job_app.errors.full_messages if job_app.errors.any?
  end
end

puts "Seeded:"
puts "#{User.count} users."
puts "#{Technology.count} technologies."
puts "#{Job.count} jobs."
puts "#{JobApplication.count} Job Applications."
