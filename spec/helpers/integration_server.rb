require "rubygems"
require "thin"
require "cgi"

Thread.abort_on_exception = true

class IntegrationServer
  def initialize(port)
    @server_thread = nil
    @port = port
    @running = false
  end

  class << self
    def base_url
      "http://localhost:#{@@port}/"
    end

    def instance
      @@instance ||= new(@@port)
    end

    def start
      instance.start
    end

    def kill
      @@instance.kill
    end

    def port=(value)
      @@port = value
    end
  end

  def run
    Thin::Server.start('0.0.0.0', @port) do
      map "/hello" do
        run HelloAdapter.new
      end

      map "/cookie_echo" do
        run CookieEchoAdapter.new
      end

      map "/host_echo" do
        run HostEchoAdapter.new
      end
    end
  end
  
  def running?
    @running
  end

  def start
    return if running?

    Thin::Logging.silent = true
    @server_thread = Thread.new do
      @server = run
    end
    sleep 0.010 unless @server && @server.running?
    @running = true
  end

  def kill
    @server_thread.kill
    @running = false
  end

  private

  class HelloAdapter
    def call(env)
      body = ["<html><head><title>hi!</title></head><body>hello</body</html>"]
      [ 200, { 'Content-Type' => 'text/html' }, body ]
    end
  end

  class CookieEchoAdapter
    def call(env)
      params = {}
      params.merge!(parse_raw_params(env["rack.input"].read))
      params.merge!(parse_raw_params(env["QUERY_STRING"]))
      
      cookies = params.inject([]) do |acc, (name, value)|
        acc << CGI::Cookie.new(name, value).to_s
        acc
      end
      cookie_string = cookies.join("\n")
      [200, { "Set-Cookie" => cookie_string }, ["echo: " + cookie_string]]
    end
    
    def parse_raw_params(input)
      return {} if input.empty?
      
      input.split(/&/).inject({}) do |parsed, pair|
        name, value = pair.split(/\=/).map {|p| CGI::unescape(p) }
        parsed[name] = value
        parsed
      end
    end
  end

  class HostEchoAdapter
    def call(env)
      [200, { 'Content-Type' => 'text/html'}, [env["HTTP_HOST"]]]
    end
  end
end
