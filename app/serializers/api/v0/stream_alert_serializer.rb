class API::V0::StreamAlertSerializer < ActiveModel::Serializer
  attributes :id,
             :signal,
             :start_time,
             :end_time,
             :alert

  belongs_to :ecg_stream, serializer: API::V0::EcgStreamSerializer
end
