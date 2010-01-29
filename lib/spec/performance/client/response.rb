
module Spec
  module Performance
    module Client

      class Response
        attr_reader :code, :body, :cookies

        def initialize(attributes = {})
          @code = attributes[:code].to_i
          @body = attributes[:body]
        end

        def success?
          @code == 200
        end

        def redirect?
          @code == 301 || @code == 302
        end
      end

    end
  end
end
