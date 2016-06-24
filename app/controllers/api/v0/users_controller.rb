class API::V0::UsersController < ApplicationController
  include Swagger::Blocks

  before_action :authenticate_api_user!, only: [:ecg_stream]

  swagger_path '/users/ecg_stream' do #collapse_start
    operation :get do
      key :description, "Get the current user's ecg stream.
                         If the current user does not have one yet, it will create an empty one for them."
      key :tags, ['Ecg Streams', 'Current User']
      parameter do
        key :name, :signal_start_time
        key :in, :query
        key :description, 'The specified starting time to receive the ecg data from'
        key :required, false
        key :type, :datetime
      end
      parameter do
        key :name, :duration
        key :in, :query
        key :description, 'The specified duration for the segment to receive, in ms'
        key :required, false
        key :type, :integer
      end
      response 200 do
        schema do
          property :data do
            property :id do
              key :type, :integer
            end
            property :type do
              key :type, :string
            end
            property :attributes do
              key :'$ref', :EcgStream
            end
            property :relationships do
              key :type, :array
              items do
                property :stream_alerts do
                  key :type, :array
                  items do
                    property :id do
                      key :type, :integer
                    end
                    property :type do
                      key :type, :string
                    end
                  end
                end
              end
            end
          end
          property :included do
            key :type, :array
            items do
              property :id do
                key :type, :integer
              end
              property :type do
                key :type, :string
              end
              property :attributes do
                key :'$ref', :StreamAlert
              end
            end
          end
        end
      end
      response :default do
        key :description, 'Various errors'
        schema do
          key :'$ref', :ErrorModel
        end
      end
    end
  end #collapse_end
  def ecg_stream
    @ecg_stream = current_api_user.get_or_create_stream

    render json: @ecg_stream, serializer: API::V0::EcgStreamSerializer, signal_start_time: params[:signal_start_time], duration: params[:duration], include: params[:include]
  end
end