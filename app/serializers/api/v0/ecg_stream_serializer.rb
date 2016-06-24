class API::V0::EcgStreamSerializer < ActiveModel::Serializer
  attributes :id,
             :signal,
             :start_time,
             :end_time,
             :created_at,
             :updated_at

  belongs_to :user, serializer: API::V0::UserSerializer
  has_many :stream_alerts, serializer: API::V0::StreamAlertSerializer

  def start_time
    get_signal_start_time
  end

  def signal
    signal = object.signal
    signal_start_time = get_signal_start_time
    duration = instance_options[:duration] ? instance_options[:duration].to_i : signal.length

    return [] if signal_start_time > object.end_time

    diff = (signal_start_time.to_f - object.start_time.to_f) * 1000 # In ms
    return signal.slice(signal.length - 10*1000/EcgStream::MS_PER_SAMPLE, signal.length) if diff <= 0

    index_offset = (diff / EcgStream::MS_PER_SAMPLE).to_i
    signal.slice(index_offset, duration)
  end

  def stream_alerts
    signal_start_time = get_signal_start_time
    signal_end_time = if instance_options[:duration]
      duration = instance_options[:duration].to_i
      Time.at(signal_start_time.to_f + duration/1000.0)
    else
      object.end_time
    end

    object.stream_alerts.where('stream_alerts.start_time BETWEEN ? and ?', signal_start_time, signal_end_time)
  end

  private

  def get_signal_start_time
    signal_start_time = if instance_options[:signal_start_time]
      Time.at(instance_options[:signal_start_time].to_f/1000.0)
    else
      [object.end_time - 10.seconds, object.start_time].max
    end

    diff = (signal_start_time.to_f - object.start_time.to_f) * 1000 # In ms
    return object.end_time - 10.seconds if diff <= 0
    signal_start_time
  end
end
