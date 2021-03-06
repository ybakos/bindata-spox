require "bindata/single"

module BinData
  # Rest will consume the input stream from the current position to the end of
  # the stream.  This will mainly be useful for debugging and developing.
  #
  #   require 'bindata'
  #
  #   class A < BinData::MultiValue
  #     string :a, :read_length => 5
  #     rest   :rest
  #   end
  #
  #   obj = A.read("abcdefghij")
  #   obj.a #=> "abcde"
  #   obj.rest #=" "fghij"
  #
  class Rest < BinData::Single

    register(self.name, self)

    #---------------
    private

    def value_to_string(val)
      val
    end

    def read_and_return_value(io)
      io.read_all_bytes
    end

    def sensible_default
      ""
    end
  end
end
