module HTTParty
  class << self

    def generate_stub method, response_filename, url, params
      %Q|stub_request(:#{method}, '#{url}')
        .with(#{params})
        .to_return(File.new('#{response_filename}'))|
    end

    def decode_ruby buffer
      buffer.string
        .gsub('=>', ': ')
        .gsub('nil', 'null')
    end

    def pp_body body
      buffer = StringIO.new

      jsonified = JSON.load body

      PP.pp(jsonified, buffer)

      buffer
    rescue
      xmldoc = REXML::Document.new body
      xmldoc.write buffer

      buffer
    end

    def adjust_content_length_for_pretty_print rsp, net_rsp
      headers = net_rsp.response.instance_variable_get :@raw_headers
      headers.gsub!(/(Content-Length|content-length)(:\s+)(\d+)/, '\1\2<CONTENTLENGTH>')
      size_without_substituion = headers.bytesize + rsp.bytesize - 15
      size = size_without_substituion + size_without_substituion.to_s.length
      headers.gsub("<CONTENTLENGTH>", size.to_s)
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

          base_file_name = "#{method}_\#{path}_\#{stmp}.txt"
          response_file_name = "response_\#{base_file_name}"

          prettied_rsp = decode_ruby(pp_body(rsp.response.body))
          adjusted_headers = adjust_content_length_for_pretty_print prettied_rsp, rsp

          File.write("stub_\#{base_file_name}", generate_stub(:#{method}, response_file_name, *args))
          File.open(response_file_name, 'w') do |f|
            f.write adjusted_headers
            f.write prettied_rsp
          end

          rsp
        end
      EOT
    end
  end
end
