class API::V0::UserSerializer < ActiveModel::Serializer
  attributes :id

  has_one :ecg_stream, serializer: API::V0::EcgStreamSerializer
end
