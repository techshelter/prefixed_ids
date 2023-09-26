module PrefixedIds
  class PrefixId
    attr_reader :hashids, :prefix

    TOKEN = "123"

    def initialize(model, prefix, salt: PrefixedIds.salt, minimum_length: PrefixedIds.minimum_length, alphabet: PrefixedIds.alphabet, delimiter: PrefixedIds.delimiter, **options)
      @prefix = prefix.to_s
      @delimiter = delimiter.to_s
      @hashids = Hashids.new("#{model.table_name}#{salt}", minimum_length, alphabet)
    end

    def encode(id)
      hex_id = id.delete("-")
      @prefix + @delimiter + @hashids.encode_hex(hex_id)
    end

    # decode returns an array
    def decode(id, fallback: false)
      puts "id: #{id}"
      fallback_value = fallback ? id : nil
      puts "fallback_value: #{fallback_value}"
      _, id_without_prefix = PrefixedIds.split_id(id, @delimiter)
      puts "id_without_prefix: #{id_without_prefix}"
      decoded_hashid = @hashids.decode_hex(id_without_prefix)
      puts "decoded_hashid: #{decoded_hashid}"
      if fallback && !valid?(decoded_hashid)
        fallback_value
      else
        # decoded_hashid.last
        res = tranform_to_uuid(decoded_hashid.downcase)
        puts "res: #{res}"
        res
      end
    end

    private

    def valid?(decoded_hashid)
      # decoded_hashid.size == 2 && decoded_hashid.first == TOKEN
      # decoded_hashid[0...TOKEN.size] == TOKEN
      true
    end

    def tranform_to_uuid(hex_string)
      "#{hex_string[0,8]}-#{hex_string[8,4]}-#{hex_string[12,4]}-#{hex_string[16,4]}-#{hex_string[20,12]}"
    end
  end
end
