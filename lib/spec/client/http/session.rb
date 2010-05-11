require "spec/client/http/request"
require "spec/client/http/response"
require "spec/client/http/transaction"
require "mechanize"
require "uri"

module Spec
  module Client
    module Http
      class Session
        attr_reader :client, :cookie_jar
        
        def initialize(client, options = {})
          @client = client
          @cookie_jar = Mechanize::CookieJar.new
        end
        
        def get(url, params = {})
          execute(Request.new(url, "GET", params, request_headers(url)))
        end
        
        def post(url, params = {})
          execute(Request.new(url, "POST", params, request_headers(url)))
        end
        
        def request_headers(url)
          { "Cookie" => @cookie_jar.cookies(URI::parse(url)) }
        end

        def execute(request)
          transaction = Transaction.new(request)
          transaction.execute
          transaction.response.cookies.each do |cookie|
            cookie_jar.add(URI::parse(transaction.request.url),cookie)
          end
          transaction
        end
      end
    end
  end
end
