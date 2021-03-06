require "bindata/single"

module BinData
  # A BinData::Stringz object is a container for a zero ("\0") terminated
  # string.
  #
  # For convenience, the zero terminator is not necessary when setting the
  # value.  Likewise, the returned value will not be zero terminated.
  #
  #   require 'bindata'
  #
  #   data = "abcd\x00efgh"
  #
  #   obj = BinData::Stringz.new
  #   obj.read(data)
  #   obj.snapshot #=> "abcd"
  #   obj.value #=> "abcd"
  #   obj.num_bytes #=> 5
  #   obj.to_s #=> "abcd\000"
  #
  # == Parameters
  #
  # Stringz objects accept all the params that BinData::Single
  # does, as well as the following:
  #
  # <tt>:max_length</tt>:: The maximum length of the string including the zero
  #                        byte.
  class Stringz < BinData::Single

    register(self.name, self)

    bindata_optional_parameters :max_length

    def value
      trim_and_zero_terminate(_value).chomp("\0")
    end

    #---------------
    private

    def value_to_string(val)
      trim_and_zero_terminate(val)
    end

    def read_and_return_value(io)
      max_length = eval_param(:max_length)
      str = ""
      i = 0
      ch = nil

      # read until zero byte or we have read in the max number of bytes
      while ch != "\0" and i != max_length
        ch = io.readbytes(1)
        str << ch
        i += 1
      end

      trim_and_zero_terminate(str)
    end

    def sensible_default
      ""
    end

    def trim_and_zero_terminate(str)
      str = truncate_at_first_zero_byte(str)
      str = trim_to(str, eval_param(:max_length))
      append_zero_byte_if_needed(str)
    end

    def truncate_at_first_zero_byte(str)
      str.sub(/([^\0]*\0).*/, '\1')
    end

    def trim_to(str, max_length = nil)
      result = str
      if max_length
        max_length = 1 if max_length < 1
        result = result[0, max_length]
        if result.length == max_length and result[-1, 1] != "\0"
          result[-1, 1] = "\0"
        end
      end
      result
    end

    def append_zero_byte_if_needed(str)
      if str.length == 0 or str[-1, 1] != "\0"
        str + "\0"
      else
        str
      end
    end
  end
end
