require 'rubygems'
require 'curb'
require 'uri'
require 'cgi'

# TODO: make an abstract parent driver class, and a spec for it

module Spec
  module Client
    module Http
      module Driver
        class CurlDriver
          def url_encode_params(params)
            return nil if params.empty?

            params.inject([]) do |query, (name, value)|
              # TODO: come up with a better way to deal with true and false parameters
              query << [name,value].collect {|s| s.nil? ? "" : s==false ? "0" : s==true ? "1" : CGI.escape(s.to_s)}.join('=')
            end.join("&")
          end

          def initialize()
          end

          def execute(url, method, headers, params)
            # Workaround for potential bug in curl
            request_url = url
            encoded_params = url_encode_params(params)

            if method == "GET"
              request_url += "?#{encoded_params}"
            end

            response_headers = {}
            response_body = ""

            curl = Curl::Easy.new(request_url)
            curl.headers = headers

            curl.on_header do |header|
              size = header.size; header.chomp!
              name, value = header.split(/\: /)
              response_headers[name] ||= []
              response_headers[name] << value
              size
            end

            body_content = ""
            curl.on_body do |body|
              body_content += body
              body.size
            end

            case method.upcase
            when "GET"
              curl.http_get
            when "POST"
              curl.http_post(encoded_params)
            end

            response = Response.new(url)
            response.code = curl.response_code
            response.headers = response_headers
            response.body = body_content
            response
          end
        end
      end
    end
  end
end
