module Spec
  module Client
    module Http
      class Transaction
        attr_reader :request, :response

        def initialize(request)
          @request = request
          @response = nil
        end

        def execute
          @response = request.execute
          self
        end

        def success?
          (200..299).include? @response.code
        end

        def redirect?
          (300..399).include? @response.code
        end
      end
    end
  end
end
