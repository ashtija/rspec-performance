require "rubygems"
require "thin"

Thread.abort_on_exception = true

class IntegrationServer
  def initialize(port)
    @server_thread = nil
    @port = port
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

  def start
    Thin::Logging.silent = true
    @server_thread = Thread.new do
      @server = Thin::Server.start('0.0.0.0', @port) do
        map "/hello" do
          run HelloAdapter.new
        end
      end
    end
    sleep 0.010 unless @server && @server.running?
  end

  def kill
    @server_thread.kill
  end

  private

  class HelloAdapter
    def call(env)
      body = ["<html><head><title>hi!</title></head><body>hello</body</html>"]
      [ 200, { 'Content-Type' => 'text/html' }, body ]
    end
  end
end
