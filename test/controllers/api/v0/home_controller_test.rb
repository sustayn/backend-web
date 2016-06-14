require 'test_helper'

class API::V0::HomeControllerTest < ActionDispatch::IntegrationTest
  test "contact route with correct params sends email" do
    deliver = stub
    deliver.expects(:deliver_later).once
    HomeMailer.expects(:contact).with('Foo Bar', 'Reaching Out', 'foo.bar@example.com', 'Hello World!').returns(deliver).once

    post '/api/v0/contact', params: { name: 'Foo Bar', contact_type: 'Reaching Out', email: 'foo.bar@example.com', message: 'Hello World!' }

    assert_response :success
    response_body = JSON.parse @response.body
    assert_not_nil response_body['meta']['success']
  end

  test "contact route with incomplete params responds with error" do
    post '/api/v0/contact'

    assert_response :bad_request
    response_body = JSON.parse @response.body
    assert_not_nil response_body['errors'][0]['title']
  end
end
