class API::V0::EcgStreamsController < ApplicationController
  include Swagger::Blocks

  before_action :authenticate_user!, only: [:log_stream]

  swagger_path '/ecg_streams/log_stream' do #swagger_start
    operation :patch do
      key :description, 'Patch data to the current users ecg stream.
                         New data posted will be appended based on the timestamps provided'
      key :tags, ['Ecg Streams']
      parameter do
        key :name, :segment
        key :in, :body
        key :description, 'The segment data to append to the end of the stream'
        key :required, true
        key :type, :array
        items do
          key :type, :integer
        end
      end
      parameter do
        key :name, :segment_start
        key :in, :body
        key :description, 'The starting timestamp for the posted segment'
        key :required, true
        key :type, :datetime
      end
      parameter do
        key :name, :segment_end
        key :in, :body
        key :description, 'The ending timestamp for the posted segment'
        key :required, true
        key :type, :datetime
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
  end #swagger_end
  def log_stream
    segment_data = ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:segment, :segment_start, :segment_end])
    render_404 and return if segment_data[:segment].blank?

    @ecg_stream = current_user.get_or_create_stream

    if @ecg_stream.append_to_stream(segment_data[:segment], segment_data[:segment_end])
      binding.pry
      render json: @ecg_stream, serializer: API::V0::EcgStreamSerializer
    else
      binding.pry
    end
  end
end
