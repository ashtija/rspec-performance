require "net/http"
require "cgi"
require "spec/performance/client/response"

module Spec
  module Performance
    module Client
      class HttpClient
        attr_writer :recording, :cookies
        attr_reader :base_uri, :cookies

        def initialize(base_uri)
          @base_uri = base_uri
          @cookies = {}
          @recording = true
        end

        def post(uri, params = {})
          request = Net::HTTP::Post.new(uri.path, headers)
          request.form_data = params
          request.basic_auth uri.user, uri.password if uri.user
          response = Net::HTTP.new(uri.host, uri.port).start do |http|
            http.request(request)
          end
          capture(response) if recording?
          create_http_client_response(response)
        end

        def get(uri, params = {})
          if params && params.size > 0
            query = params2query(params)
            uri = URI.parse("#{uri}?#{query}")
          end

          http = Net::HTTP.start(uri.host, uri.port)
          p uri.request_uri
          p browser_cookies
          response = http.get(uri.request_uri, { "Cookie: " => browser_cookies })
          http.finish

          create_http_client_response(response)
        end

        def recording?
          @recording
        end

        private

        def params2query(hash)
          q = hash.inject([]) do |acc, (k, v)|
            acc << CGI::escape(k.to_s) + "=" + CGI::escape(v.to_s)
          end.join("&")
        end

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

        def headers
          @cookies.values.inject({}) do |acc, cookie|
            acc["Cookie"] = cookie.to_s
            acc
          end
        end

        def browser_cookies
          cookies_to_send = @cookies.values.reject {|cookie| cookie.name == "path" || cookie.name == "domain" }
          cookies_to_send.map do |cookie|
            CGI::escape(cookie.name) + "=" + CGI::escape(cookie.value.first)
          end.join("&")
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
