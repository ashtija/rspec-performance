require "rubygems"
require "thin"

Thread.abort_on_exception = true

class IntegrationServer
  def initialize(port)
    @server_thread = nil
    @port = port
    @running = false
  end

  def self.base_url
    "http://localhost:#{@@port}/"
  end

  def self.instance
    @@instance ||= new(@@port)
  end

  def self.start
    instance.start
  end

  def self.kill
    @@instance.kill
  end

  def self.port=(value)
    @@port = value
  end

  def running?
    @running
  end

  def start
    return if running?

    Thin::Logging.silent = true
    @server_thread = Thread.new do
      @server = Thin::Server.start('0.0.0.0', @port) do
        map "/hello" do
          run HelloAdapter.new
        end

        map "/cookie_echo" do
          run CookieEchoAdapter.new
        end
      end
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
      cookies = env["rack.input"].read.split(/&/).inject([]) do |acc, pair|
        name, value = pair.split(/=/).map {|p| CGI::unescape(p) }
        acc << CGI::Cookie.new(name, value).to_s
        acc
      end
      cookie_string = cookies.join("\n")
      [200, { "Set-Cookie" => cookie_string }, ["echo"]]
    end
  end
end
