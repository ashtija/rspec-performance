require "#{File.dirname(__FILE__)}/../../../../spec_helper"

describe Spec::Performance::Example::PerformanceExampleGroupMethods do
  describe "#perform" do
    it "runs the performance loop runs N times where N is equal to iterations divided by concurrency"
  
    it "executes the performance loop in the same context as the other examples" do
      example_group = Class.new(Spec::Performance::Example::PerformanceExampleGroup)
    
      example_group.before do
        @scope = self
        @foo = "bar"
      end 
    
      executed = false
      example_group.perform "do performance loop", :concurrency => 1, :iterations => 1 do
        (@scope == self).should be_true
        @foo.should == "bar"
        executed = true
      end
      
      options = ::Spec::Runner::Options.new(StringIO.new, StringIO.new)
      example_group.run(options)
    
      @scope.should be_nil
      @foo.should_not == "bar"
      executed.should be_true
    end
  
    it "fails when it does not match on iterations per second"
  
    it "fails when the mean iteration execution time does not land at or below the configured maximum mean iteration execution time"
  end
end