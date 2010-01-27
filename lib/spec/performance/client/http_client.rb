require "net/http"

module Spec
  module Performance
    module Client
      class HttpClient
        attr_writer :recording

        def initialize
          #    @recording = true
        end

        def post(uri, params)
          Net::HTTP.post_form(uri, params)
          #    response = HTTP.post(url, params)
          #    capture(response) if recording?
        end

        def get(uri, params)
        end

        def recording?
          #    @recording
        end

#        def restore
#        end

        private
        def capture(response)
          # get all the cookies and add to cookie jar
        end
      end
    end
  end
end
