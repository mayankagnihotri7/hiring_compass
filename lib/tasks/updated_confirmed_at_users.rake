task :updated_confirmed_at_users => :environment do
  User.all.find_each do |user|
    user.update(confirmed_at: DateTime.now)
  end
end