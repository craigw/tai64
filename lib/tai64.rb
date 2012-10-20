require "tai64/version"

module Tai64
  EPOCH = 2 ** 62
  MAXIMUM = 2 ** 63

  def self.parse str
    Label.new str
  end

  class Label
    attr_accessor :str
    private :str=, :str

    attr_accessor :leap_second_fudge
    private :leap_second_fudge=, :leap_second_fudge

    attr_accessor :nano_second_fudge
    private :nano_second_fudge=, :nano_second_fudge

    def initialize str, leap_second_fudge = 10, nano_second_fudge = 500
      self.str = str.gsub /^@/, ''
      self.leap_second_fudge = leap_second_fudge
      self.nano_second_fudge = nano_second_fudge
    end

    def to_s
      "@#{str}" % tai_parts
    end

    def tai_second
      s = str.scan(/^\@?([0-9abcdef]{16})/i)[0][0].to_i(16)
      if s.between? 0, EPOCH - 1
        tai_second = EPOCH - s
      elsif s.between? EPOCH, MAXIMUM
        tai_second = s - EPOCH
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
      t = Time.at utc_reference
      t.utc
    end
  end
end
