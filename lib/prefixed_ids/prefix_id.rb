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
      fallback_value = fallback ? id : nil
      _, id_without_prefix = PrefixedIds.split_id(id, @delimiter)
      # decoded_hashid = @hashids.decode_hex(id_without_prefix) rescue id
      decoded_hashid = decode_hex(@hashids, id_without_prefix) rescue id
      if fallback && !valid?(decoded_hashid, id)
        fallback_value
      else
        tranform_to_uuid(decoded_hashid.downcase)
      end
    end

    private

    def valid?(decoded_hashid, id)
      decoded_hashid != id
    end

    def tranform_to_uuid(hex_string)
      "#{hex_string[0,8]}-#{hex_string[8,4]}-#{hex_string[12,4]}-#{hex_string[16,4]}-#{hex_string[20,12]}"
    end

    def decode_hex(hash, str)
      res = hash.decode_hex(str)
      raise Hashids::InputError if res.empty?
      res
    end
  end
end
