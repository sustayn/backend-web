class EcgStream < ApplicationRecord
  include Swagger::Blocks

  ALLOWABLE_STREAM_LENGTH = 1.0*60.0*1000.0 # In ms
  MS_PER_SAMPLE = 4.0 # In ms
  ALLOWABLE_STREAM_ARRAY_LENGTH = ALLOWABLE_STREAM_LENGTH / MS_PER_SAMPLE # Maximum array length
  ALLOWABLE_DROPPED_PERIOD = 2.0*1000.0 # In ms, the maximum time allowed between signal end and segment start times
  BASELINE_VALUE = 512 # Integer, for normalizing data

  swagger_schema :EcgStream do #collapse_start
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
  end #collapse_end

  belongs_to :user
  has_many :stream_alerts, dependent: :destroy

  def attributes_from_start_time(signal_start_time, duration)
    if signal_start_time > end_time
      return { signal: [], start_time: DateTime.now, end_time: DateTime.now }
    end
  end

  def append_to_stream(segment, segment_start, segment_end)
    dropped_diff = (segment_start.to_f - end_time.to_f) * 1000

    # Two conditions
    # 1) The ecg stream has no data
    # 2) The difference between the latest update and the last update is too great
    # In both cases we just want to reset it
    if signal.empty? || dropped_diff > ALLOWABLE_DROPPED_PERIOD
      return self.update_attributes(signal: segment, start_time: segment_start, end_time: segment_end)
    end

    new_signal = if dropped_diff > 0
      #Add some filler values for the time difference
      filler_length = (dropped_diff / MS_PER_SAMPLE).to_i
      signal.concat(Array.new(filler_length, BASELINE_VALUE)).concat(segment)
    elsif dropped_diff < 0
      cut_length = -(dropped_diff / MS_PER_SAMPLE).to_i
      signal.slice(0, signal.length - cut_length).concat(segment)
    else
      signal.concat(segment)
    end

    # Slice an array of length for one minute, based off of a 4 MS sample rate
    if new_signal.length > ALLOWABLE_STREAM_ARRAY_LENGTH
      # Get the amount of indices over the allowed length
      diff = new_signal.length - ALLOWABLE_STREAM_ARRAY_LENGTH
      # Get the new start time by adding the time taken up by the diff
      new_start_time = start_time.to_f + (diff * MS_PER_SAMPLE)/1000.0
      # Slice the new array to exactly the allowable length
      new_signal = new_signal.slice(-ALLOWABLE_STREAM_ARRAY_LENGTH, ALLOWABLE_STREAM_ARRAY_LENGTH)
      return self.update_attributes(signal: new_signal, start_time: Time.at(new_start_time), end_time: segment_end)
    else
      return self.update_attributes(signal: new_signal, end_time: segment_end)
    end
  end

  # TODO: Refactor to ruby object
  def detect_segment_errors(segment, segment_start, segment_end) #collapse_start
    segment_length = segment.length
    averaged_segment = Array.new(segment_length)
    local_maxes = Array.new

    # Smooth the data by taking the averages
    for i in 0...segment_length
      if i == 0
        averaged_segment[i] = segment.slice(0,3).inject(:+).to_f / 3.0
      elsif i == 1
        averaged_segment[i] = segment.slice(0,4).inject(:+).to_f / 4.0
      elsif i == segment_length-1
        averaged_segment[i] = segment.slice(segment_length-3, 3).inject(:+).to_f / 3.0
      elsif i == segment_length-2
        averaged_segment[i] = segment.slice(segment_length-4, 4).inject(:+).to_f / 4.0
      else
        averaged_segment[i] = segment.slice(i-2, 4).inject(:+).to_f / 4.0
      end
    end

    # Find all the local maxes in the data, that can correspond to qrs segments or smaller local maxes
    j = 0
    while j < segment_length
      current = averaged_segment[j]
      local_max = true

      if (current - BASELINE_VALUE) > 20
        starting = [j-10, 0].max
        ending = [j+10, segment_length].min
        for k in starting...ending
          if averaged_segment[k] > current
            local_max = false
            break
          end
        end

        if local_max
          if (current - 512) > 250
            local_maxes.push({ index: j, type: 'qrs' })
          else
            local_maxes.push({ index: j, type: 'small' })
          end
          j += 10
        end
      end
      j += 1
    end

    distances = Array.new
    flutters = Array.new
    w = 0

    # Find the distances between qrs segments
    # Find the number of small local maxes in between qrs segments (corresponding to atrial flutters)
    while w < local_maxes.length - 1
      current = local_maxes[w]
      if current[:type] == 'qrs'
        idx = w+1
        counter = 0

        while idx < local_maxes.length
          if local_maxes[idx][:type] == 'qrs'
            distances.push({
              start: current[:index],
              stop: local_maxes[idx][:index],
              distance: local_maxes[idx][:index] - current[:index]
            })
            if counter >= 4
              flutters.push({
                start: current[:index],
                stop: local_maxes[idx][:index],
                distance: local_maxes[idx][:index] - current[:index]
              })
            end
            break;
          end

          counter += 1
          idx += 1
        end

        w = idx
      else
        w += 1
      end
    end

    max_distance = distances.max_by { |obj| obj[:distance] }[:distance]
    min_distance = distances.min_by { |obj| obj[:distance] }[:distance]
    long_distances = Array.new
    if max_distance - min_distance > 75
      long_distances = distances.select { |obj| obj[:distance] > max_distance-25 }
      long_distances = long_distances.reduce([]) do |memo, val|
        last = memo.last
        if last
          if last[:stop] == val[:start]
            last[:stop] = val[:stop]
            last[:distance] = last[:distance] + val[:distance]
            memo[-1] = last

            memo
          else
            memo.push(val)
          end
        else
          [val]
        end
      end
    end

    long_distances.each do |dist_obj|
      signal = segment.slice(dist_obj[:start], dist_obj[:distance])

      StreamAlert.create({
        signal: signal,
        start_time: Time.at(segment_start.to_f + dist_obj[:start]*MS_PER_SAMPLE/1000.0),
        end_time: Time.at(segment_start.to_f + dist_obj[:stop]*MS_PER_SAMPLE/1000.0),
        alert: 'Sinus Arrythmia',
        ecg_stream_id: self.id
      })
    end

    flutters.each do |flutter_obj|
      signal = segment.slice(flutter_obj[:start], flutter_obj[:distance])

      StreamAlert.create({
        signal: signal,
        start_time: Time.at(segment_start.to_f + flutter_obj[:start]*MS_PER_SAMPLE/1000.0),
        end_time: Time.at(segment_start.to_f + flutter_obj[:stop]*MS_PER_SAMPLE/1000.0),
        alert: 'Atrial Flutter',
        ecg_stream_id: self.id
      })
    end
  end #collapse_end
end
