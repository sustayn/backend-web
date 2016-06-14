class EcgStream < ApplicationRecord
  include Swagger::Blocks

  swagger_schema :EcgStream do
    key :required, [:id, :signal, :start_time, :end_time, :user_id]
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
    property :user_id do
      key :type, :integer
    end
    property :created_at do
      key :type, :string
    end
    property :updated_at do
      key :type, :string
    end
  end

  belongs_to :user
  has_many :stream_alerts, dependent: :destroy

  def attributes_from_start_time(signal_start_time, duration)
    if signal_start_time > end_time
      return { signal: [], start_time: DateTime.now, end_time: DateTime.now }
    end

  end

  def append_to_stream(segment, segment_end)
    new_signal = signal.concat(segment)
    # Slice an array of length for one minute, based off of a 4 MS sample rate
    if new_signal.length > (1000/4 * 60)
      # Get the amount of indices over the allowed length
      diff = new_signal.length - (1000/4 * 60)
      # Get the new start time by adding the time taken up by the diff
      new_start_time = start_time.to_f + (diff * 4.0)/1000.0
      # Slice the new array
      new_signal = new_signal.slice(-(1000/4 * 60), (1000/4 * 60))
      return self.update_attributes(signal: new_signal, start_time: new_start_time, end_time: segment_end)
    else
      return self.update_attributes(signal: new_signal, end_time: segment_end)
    end
  end
end
