require "net/http"
require "cgi"
require "spec/performance/client/response"

module Spec
  module Performance
    module Client
      class HttpClient
        attr_writer :recording
        attr_reader :cookies

        def initialize
          @cookies = {}
          @recording = true
        end

        def post(uri, params)
          response = Net::HTTP.post_form(uri, params)
          capture(response) if recording?
          create_http_client_response(response)
        end

        def get(uri, params)
        end

        def recording?
          @recording 
        end

        private
        def capture(response)
          if raw_cookies = response.get_fields("Set-Cookie")
            cookie_jar = raw_cookies.inject({}) do |parsed_cookies, raw_cookie_string|
              CGI::Cookie.parse(raw_cookie_string).each do |name, cookie|
                parsed_cookies[name.to_sym] = cookie
              end
              parsed_cookies
            end
            @cookies.merge!(cookie_jar)
          end
        end

        def create_http_client_response(net_http_response)
          attributes = { :code => net_http_response.code,
                         :body => net_http_response.body  }
          Response.new(attributes)
        end
      end
    end
  end
end
