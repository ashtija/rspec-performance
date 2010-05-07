require "spec/client/http/request"
require "mechanize"
require "uri"

module Spec
  module Client
    module Http
      class Response
        attr_accessor :code, :headers, :body

        def initialize(url)
          @code = 0
          @headers = {}
          @body = ""
          @url = url
        end

        def cookies
          # TODO: can probably use ruby tricks to bind these together rather than using a temporary array...
          tmp_cookies = []
          (headers["Set-Cookie"]||[]).map do |raw_cookie|
            uri = URI::parse(@url)
            Mechanize::Cookie::parse(uri,raw_cookie) do |c|
              tmp_cookies.push(c)
            end
          end
          tmp_cookies
        end
      end
    end
  end
end
