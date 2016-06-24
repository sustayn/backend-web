class StreamAlert < ApplicationRecord
  include Swagger::Blocks

  swagger_schema :StreamAlert do #collapse_start
    key :required, [:id, :signal, :start_time, :end_time, :ecg_stream_id]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :signal do
      key :type, :array
      items do
        key :type, :integer
      end
    end
    property :start_time do
      key :type, :datetime
    end
    property :end_time do
      key :type, :datetime
    end
    property :alert do
      key :type, :string
      key :description, 'A string designating the type of alert'
    end
    property :ecg_stream_id do
      key :type, :integer
    end
    property :created_at do
      key :type, :string
    end
    property :updated_at do
      key :type, :string
    end
  end #collapse_end

  belongs_to :ecg_stream
end
