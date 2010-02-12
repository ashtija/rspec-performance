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
        end
        
        def redirect?
        end
      end
    end
  end
end
