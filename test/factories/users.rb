FactoryGirl.define do
  factory :user do
    first_name 'Foo'
    last_name 'Bar'
    sequence(:email) { |n| "email#{n}@example.com" }
  end
end
