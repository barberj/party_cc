module HTTParty
  class << self
    def decode_ruby buffer
      buffer.string
        .gsub('=>', ': ')
        .gsub('nil', 'null')
    end

    request_methods = ['get', 'post', 'patch', 'put', 'delete', 'head', 'options']
    request_methods.each do |method|
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        alias_method :old_#{method}, :#{method}

        def #{method} *args
          rsp = old_#{method}(*args)

          stmp = Time.now.to_i.to_s
          path = Addressable::URI.parse(args[0])
            .path.split('/').join('_').gsub(/^_/,'')

          file_name = "#{method}_\#{path}_\#{stmp}.txt"

          req_buffer = StringIO.new
          rsp_buffer = StringIO.new

          PP.pp(args, req_buffer)
          PP.pp(rsp, rsp_buffer)

          prettied_req = decode_ruby req_buffer
          prettied_rsp = decode_ruby rsp_buffer

          File.write("request_\#{file_name}", prettied_req)
          File.open("response_\#{file_name}", 'w') do |f|
            f.write rsp.response.instance_variable_get :@raw_headers
            f.write ''
            f.write prettied_rsp
          end

          rsp
        end
      EOT
    end
  end
end
