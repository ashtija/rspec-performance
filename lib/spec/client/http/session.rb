require "spec/client/http/request"
require "spec/client/http/response"
require "spec/client/http/cookie_jar"

module Spec
  module Client
    module Http
      class Session
        attr_reader :cookie_jar
        
        def initialize(options = {})
          @cookie_jar = CookieJar.new
        end
        
        def get(url, params = {})
          execute(GetRequest.new(url, params, request_headers(url)))
        end
        
        def post(url, params = {})
          execute(PostRequest.new(url, params, request_headers(url)))
        end
        
        def request_headers(url)
          raise "not implemented"
          uri = URI.parse(url)
          { "Cookie" => cookie_jar.to_s(uri.domain, uri.path) }
        end
        
        private
        
        def execute(request)
          raise "not implemented"
          transaction = Transaction.new(request).execute
          transaction.response.cookies.each do |cookie|
            cookie_jar.add(cookie)
          end
        end
      end
    end
  end
end