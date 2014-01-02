require "party_cc/version"
require 'httparty'
require 'addressable/uri'
require 'pp'

module HTTParty
  class << self
    request_methods = ['get', 'post', 'patch', 'put', 'delete', 'head', 'options']
    request_methods.each do |method|
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        alias_method :old_#{method}, :#{method}

        def #{method} *args
          old_#{method}(*args).tap do |rsp|

            stmp = Time.now.to_i.to_s
            path = Addressable::URI.parse(args[0])
              .path.split('/').join('_').gsub(/^_/,'')

            file_name = "#{method}_\#{path}_\#{stmp}.txt"

            req_buffer = StringIO.new
            rsp_buffer = StringIO.new

            PP.pp(args, req_buffer)
            PP.pp(rsp, rsp_buffer)

            prettied_req = req_buffer.string
              .gsub('=>', ': ')
              .gsub('nil', 'null')

            prettied_rsp = rsp_buffer.string
              .gsub('=>', ': ')
              .gsub('nil', 'null')

            File.open(file_name, 'w') do |fh|
              fh.write "Request [#{method}]\n"
              fh.write "\#{prettied_req}\n"
              fh.write "Response\n"
              fh.write "\#{prettied_rsp}"
            end
          end
        end
      EOT
    end
  end
end

module PartyCC; end
