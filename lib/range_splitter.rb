class Range
  # Will split a Range of Integers or Strings into a number of groups
  # and optionally shift by endianness. If no options are given, the range
  # will be split into 2 with the largest range(s) at the beginning.
  #
  # examples:
  #     (1..10).split
  #     # => [1..5, 6..10]
  #
  #     (1..10).split(into: 3)
  #     #=> [1..4, 5..7, 8..10]
  #
  #     ('a'..'m').split(into: 3, endianness: :little)
  #     #=> ["a".."d", "e".."h", "i".."m"]
  #
  def split(params = {})
    into = Into.new(params[:into])
    into.validate!
    return [self] unless into.is_divisible?

    endianness = Endianness.new(params[:endianness])
    endianness.validate!

    validate_split_type!

    partition = Partition.build(min, max, count, into.num_parts)
    return [self] if partition.at_end?

    partition.decrement! if endianness.little?

    head = min..partition.at
    tail = (partition.next..max).split(params.merge!(:into => into.decrement))

    [head] + tail
  end

  private

  def validate_split_type!
    unless self.min.is_a?(Fixnum) || self.min.is_a?(String)
      raise TypeError.new("Can't split through #{min.class}")
    end
  end

  class Partition

    attr_reader :at

    def self.build(min, max, count, num_par)
      case min
      when ::Fixnum
        Partition::Integer.new(min, max, count, num_par)
      when ::String
        Partition::String.new(min, max, count, num_par)
      end
    end

    def initialize(min, max, count, num_parts)
      @max = max.ord
      @at = min.ord + (count.to_f / num_parts).ceil - 1
    end

    def at_end?
      @at == @max
    end

    def decrement!
      @at -= 1
    end

    private

    class String < Partition
      def at
        [@at].pack('U')
      end

      def next
        [@at + 1].pack('U')
      end
    end

    class Integer < Partition
      def next
        @at += 1
      end
    end
  end

  class Into
    DEFAULT_NUM_PARTS = 2

    attr_reader :num_parts

    def initialize(num_parts)
      @num_parts = num_parts || DEFAULT_NUM_PARTS
    end

    def validate!
      unless is_positive_integer?
        err = "Cannot split #{self} into #{num_parts} ranges."
        raise ArgumentError.new(err)
      end
    end

    def decrement
      num_parts - 1
    end

    def is_divisible?
      num_parts > 1
    end

    def is_positive_integer?
      num_parts.is_a?(Fixnum) && num_parts > 0
    end
  end

  class Endianness
    BIG = :big
    LITTLE = :little

    attr_reader :endianness

    def initialize(endianness)
      @endianness = endianness || BIG
    end

    def validate!
      unless valid?
        err = "The endianness parameter must be either #{BIG} or #{LITTLE}"
        raise ArgumentError.new(err)
      end
    end

    def little?
      endianness == LITTLE
    end

    def valid?
      [BIG, LITTLE].include?(endianness)
    end
  end
end
