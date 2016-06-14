class API::V0::EcgStreamSerializer < ActiveModel::Serializer
  attributes :id, :signal, :start_time, :end_time, :created_at, :updated_at

  belongs_to :user, serializer: API::V0::UserSerializer
  has_many :stream_alerts, serializer: API::V0::StreamAlertSerializer
end
