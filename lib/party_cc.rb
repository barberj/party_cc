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

            buffer = StringIO.new
            PP.pp(rsp, buffer)

            prettied_rsp = buffer.string
              .gsub('=>', ': ')
              .gsub('nil', 'null')

            File.write(file_name, prettied_rsp) do |f|
              PP.pp(rsp, f)
            end
          end
        end
      EOT
    end
  end
end

module PartyCC; end
