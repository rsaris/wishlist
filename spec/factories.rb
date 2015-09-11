FactoryGirl.define do
  factory :user do
    full_name 'Test User'
    email 'default@test.com'
    password 'password'
    password_confirmation 'password'
  end
end