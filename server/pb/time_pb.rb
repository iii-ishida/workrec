module TimePb
  require 'google/protobuf/timestamp_pb'

  refine Time do
    def to_pb
      Google::Protobuf::Timestamp.new(seconds: tv_sec, nanos: tv_usec) 
    end
  end

  refine Google::Protobuf::Timestamp do
    def to_time
      Time.at(seconds, nanos)
    end
  end
end
