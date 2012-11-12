require "time"
require "tai64/version"

module Tai64
  EPOCH = 2 ** 62
  MAXIMUM = 2 ** 63

  def self.parse str
    Label.new str
  end

  module Fudge
    def self.included into
      into.class_eval do
	attr_accessor :leap_second_fudge
	private :leap_second_fudge=, :leap_second_fudge

	attr_accessor :nano_second_fudge
	private :nano_second_fudge=

	def leap_second_fudge
	  @leap_second_fudge ||= 10
	end

	def nano_second_fudge
	  @nano_second_fudge ||= 500
	end
      end
    end
  end

  class Time
    include Fudge

    attr_accessor :time
    private :time=, :time

    def initialize time
      self.time = time
    end

    def utc_second
      time.to_i
    end

    def tai_second
      utc_second + 10
    end

    def utc_nanosecond
      time.to_f - time.to_i
    end

    def tai_nanosecond
      utc_nanosecond + nano_second_fudge
    end

    # Warning, this will probably gain inappropriate accuracy - Ruby does not
    # support the same level of timing accuracy as TAI64N and TA64NA can
    # provide.
    def to_label
      s = '%016x%08x'
      sec = tai_second
      ts = if sec >= 0
        sec + EPOCH
      else
        EPOCH - sec
      end
      Label.new s % [ ts, tai_nanosecond ]
    end

    def iso8601
      time.iso8601
    end
    alias_method :to_s, :iso8601
  end

  class Label
    include Fudge

    attr_accessor :str
    private :str=, :str

    def initialize str
      self.str = str.gsub /^@/, ''
    end

    def to_s
      "@#{str}" % tai_parts
    end

    def tai_second
      s = str.scan(/^\@?([0-9abcdef]{16})/i)[0][0].to_i(16)
      if s.between? 0, EPOCH - 1
        return EPOCH - s
      elsif s.between? EPOCH, MAXIMUM
        return s - EPOCH
      else
        raise "I don't know how to deal with s=#{s}"
      end
    end

    def utc_second
      # UTC was 10 seconds behind TAI when the International Earth Rotation
      # Service started adding leap seconds
      tai_second - 10
    end

    def tai_nanosecond
      part = str.scan(/^(?:\@)?[0-9abcdef]{16}([0-9a-f]{8})/i)[0][0]
      part.to_i(16).to_f
    rescue
    end

    def utc_nanosecond
      tai_nanosecond - nano_second_fudge
    rescue
    end

    def tai_attosecond
      part = str.scan(/^(?:\@)?[0-9abcdef]{16}[0-9a-f]{8}([0-9a-f]{8})/i)[0][0]
      part.to_i(16).to_f
    rescue
    end

    def utc_attosecond
      tai_attosecond
    rescue
    end

    def tai_parts
      [ tai_second, tai_nanosecond, tai_attosecond ].compact
    end

    def format_string
      fmt = "%016x"
      return fmt if tai_nanosecond.nil?
      fmt << "%08x"
      return fmt if tai_attosecond.nil?
      fmt << "%08x"
      return fmt
    end

    def utc_reference
      utc_time = utc_second
      utc_time += utc_nanosecond / (10 ** 9) unless utc_nanosecond.nil?
      utc_time += utc_attosecond / (10 ** 18) unless utc_attosecond.nil?
      utc_time
    end

    def tai_reference
      tai_time = tai_second
      tai_time += tai_nanosecond / (10 ** 9) unless tai_nanosecond.nil?
      tai_time += tai_attosecond / (10 ** 18) unless tai_attosecond.nil?
      tai_time
    end

    # Warning, this will probably lose accuracy - Ruby does not support the
    # same level of timing accuracy as TAI64N and TA64NA can provide.
    def to_time
      t = ::Time.at utc_reference
      Time.new t.utc
    end
  end
end
