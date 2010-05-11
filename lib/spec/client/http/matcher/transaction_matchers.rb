module Spec
  module Client
    module Http
      module Matcher
        module TransactionMatchers
          class VerboseHttpMatcher
            attr_accessor :transaction

            def matches?(transaction)
              @transaction = transaction
              return transaction.is_a?(Spec::Client::Http::Transaction)
            end

            def transaction_info
                "Request: #{transaction.request.url} using #{transaction.request.request_method}" + "\n" +
                "  sent headers: #{transaction.request.headers}" + "\n" +
                "  sent params: #{transaction.request.url_encoded_params}" + "\n" +
                "Response code: #{transaction.response.code}" + "\n" +
                "  with cookies: #{transaction.response.cookies}" + "\n" +
                "  with html body: #{transaction.response.body}"
            end

            def failure_message
              transaction_info
            end

            def negative_failure_message
              transaction_info
            end
          end

          class BeRedirect < VerboseHttpMatcher
            def matches?(transaction)
              super(transaction) && transaction.redirect?
              #(300..399).include? transaction.response.code
            end

            def failure_message
              "expected redirect? to return true, got false" + "\n" + super
            end

            def negative_failure_message
              "expected redirect? to return false, got true" + "\n" + super
            end
          end

          def be_redirect
            BeRedirect.new()
          end

          class BeSuccess < VerboseHttpMatcher
            def matches?(transaction)
              super(transaction) && transaction.success?
              #(200..299).include? transaction.response.code
            end

            def failure_message
              "expected success? to return true, got false" + "\n" + super
            end

            def negative_failure_message
              "expected success? to return false, got true" + "\n" + super
            end
          end

          def be_success
            BeSuccess.new()
          end
        end
      end
    end
  end
end

