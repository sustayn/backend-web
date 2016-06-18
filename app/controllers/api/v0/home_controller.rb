class API::V0::HomeController < ApplicationController
  include Swagger::Blocks

  swagger_path '/contact' do #swagger_start
    operation :post do
      key :description, 'Sends a message to the contact account'
      key :tags, ['Home']
      parameter do
        key :name, :name
        key :in, :body
        key :description, 'The name of the request'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :contact_type
        key :in, :body
        key :description, 'The type of request'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :email
        key :in, :body
        key :description, 'The email to send from'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :message
        key :in, :body
        key :description, 'The message to send'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'Success message'
        schema do
          key :'$ref', :SuccessResponse
        end
      end
      response 400 do
        key :description, 'Insufficient Params'
        schema do
          key :'$ref', :ErrorModel
        end
      end
    end
  end #swagger_end
  def contact
    name = params[:name] || 'Anonymous'
    subject = params[:contact_type] || 'No Subject'
    email = params[:email]
    message = params[:message]

    if email && message
      HomeMailer.contact(name, subject, email, message).deliver_later
      render json: { meta: { success: "Got it - we'll get back to you soon!" } }, status: :ok
    else
      render json: { errors: [{ title: 'Requires an email and message' }] }, status: :bad_request
    end
  end
end
