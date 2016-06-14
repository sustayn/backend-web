class API::V0::UsersController < ApplicationController
  include Swagger::Blocks

  before_action :authenticate_user!, only: [:ecg_stream]

  swagger_path '/users/ecg_stream' do
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
  end
  def ecg_stream
    @ecg_stream = current_user.get_or_create_stream

    render json: @ecg_stream, serializer: API::V0::EcgStreamSerializer, include: { stream_alerts: {} }
  end
end
# show: function(req, res) {
#     if(!req.user || !req.user.id || !req.params || !req.params.id) {
#       return res.status(404).json({ errors: {error: 'Error retrieving the current user'} });
#     }
#     if(parseInt(req.user.id) !== parseInt(req.params.id)) {
#       return res.status(401).json({ errors: {error: 'Unauthorized to view the stream for this user'} });
#     }
#     EcgStream.forge({userId: req.params.id})
#     .fetch({withRelated: ['streamAlerts']})
#     .then(function(ecgStream) {
#       if(ecgStream) {
#         ecgStream.getAttributesFromStartTime(req.query.signalStartTime, req.query.duration)
#         .then(function(ecgStreamData) {
#           var relevantAlerts = _.filter(ecgStream.related('streamAlerts').models, function(streamAlert) {
#             var saStartTime = moment(streamAlert.attributes.startTime);
#             var saEndTime = moment(streamAlert.attributes.endTime);
#             var ecgStartTime = moment(ecgStreamData.attributes.startTime);
#             var ecgEndTime = moment(ecgStreamData.attributes.endTime);

#             var queryStart = parseInt(req.query.signalStartTime) || ecgStartTime.valueOf();
#             return (saStartTime.valueOf() >= ecgStartTime.valueOf()) && (saEndTime.valueOf() <= ecgEndTime.valueOf());
#           });

#           return res.status(200).json({
#             data: {
#               type: 'ecg-streams',
#               id: ecgStreamData.id,
#               attributes: _.pick(ecgStreamData.attributes, 'signal', 'startTime', 'endTime', 'userId'),
#               relationships: {
#                 'stream-alerts': {
#                   data: _.map(relevantAlerts, function(streamAlert) {
#                     return { type: 'stream-alerts', id: streamAlert.id };
#                   })
#                 }
#               }
#             },
#             included: _.map(relevantAlerts, function(streamAlert) {
#               return {
#                 id: streamAlert.id,
#                 type: 'stream-alerts',
#                 attributes: _.pick(streamAlert.attributes, 'signal', 'startTime', 'endTime', 'alert')
#               };
#             })
#           });
#         });
#       } else {
#         EcgStream.forge({
#           signal: [],
#           userId: parseInt(req.params.id)
#         })
#         .save()
#         .then(function(ecgStreamData) {
#           return res.status(200).json({
#             data: {
#               type: 'ecg-streams',
#               id: ecgStreamData.id,
#               attributes: _.pick(ecgStreamData.attributes, 'signal', 'startTime', 'endTime', 'userId')
#             }
#           });
#         });
#       }
#     })
#     .catch(function(err) {
#       return res.status(404).json({ errors: {error: 'Unable to find a stream for this user'} });
#     });
#   },