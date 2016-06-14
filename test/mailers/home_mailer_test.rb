require 'test_helper'

class HomeMailerTest < ActionMailer::TestCase
  test "contact email" do
    email = HomeMailer.contact('Foo', 'My Subject', 'foo.bar@example.com', 'Hello World!').deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal ['foo.bar@example.com'], email.from
    assert_equal ['contact@corvae.com'], email.to
    assert_equal 'My Subject', email.subject
    assert_match /From: Foo/, email.encoded
    assert_match /Hello World!/, email.encoded
  end
end
