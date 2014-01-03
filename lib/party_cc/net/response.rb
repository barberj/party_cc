class Net::HTTPResponse
  class << self
    alias_method :orig_read_new, :read_new
    def read_new(sock)
      buffer = StringBufferedIO.new

      loop do
        chunk = sock.readuntil("\n", true)
        buffer.write chunk
        break if chunk.sub(/\s+\z/, '').empty?
      end

      buffer.rewind

      httpv, code, msg = read_status_line(buffer)

      res = response_class(code).new(httpv, code, msg)
      each_response_header(buffer) do |k,v|
        res.add_field k, v
      end
      res.instance_variable_set :@raw_headers, buffer.string
      res
    end
  end
end
