FactoryBot.define do
  factory :job_application do
    association :job

    first_name { Faker::Name.first_name }
    last_name {Faker::Name.last_name}
    years_of_experience { rand(0..12) }
    email { Faker::Internet.unique.email }
    visa_sponsorship_required { false }
    phone_number { ["+1 555 123 4567", "+44 20 7946 0858", "+91 98765 43210"].sample }
    status { JobApplication.statuses.keys.sample.to_s }
    
    after(:build) do |job_app|
      file_path = Rails.root.join("tmp", "Mayank Agnihotri.pdf")
      job_app.resume.attach(
        io: File.open(file_path),
        filename: "Mayank Agnihotri.pdf",
        content_type: "application/pdf"
      )
    end
  end
end