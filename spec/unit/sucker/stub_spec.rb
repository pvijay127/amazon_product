require "spec_helper"
require "fileutils"

module Sucker
  describe "Stub" do
    before do
      @worker = Sucker.new(
        :locale => "us",
        :secret => "secret")
    end

    context ".stub" do
      before do
        Sucker.stub(@worker)
      end

      after do
        FileUtils.rm @worker.fixture, :force => true
      end

      it "defines Request#fixture" do
        @worker.should respond_to :fixture
        @worker.fixture.should include Sucker.fixtures_path
      end

      it "performs the request if fixture is not available" do
        curl = @worker.curl
        curl.stub(:get).and_return(nil)
        curl.stub!(:body_str).and_return("foo")

        @worker.get

        File.exists?(@worker.fixture).should be_true
        File.new(@worker.fixture, "r").read.should eql "foo"
      end

      it "mocks the request if fixture is available" do
        File.open(@worker.fixture, "w") { |f| f.write "bar" }

        @worker.get.body.should eql "bar"
      end

      context "defines:" do
        context "#fixture" do
          it "generates a path for the fixture" do
            @worker.fixture.should match /.*\/[0-9a-f]{32}\.xml$/
          end

          it "generates unique fixtures across venues" do
            us_fixture = @worker.fixture
            @worker.locale = "fr"
            @worker.fixture.should_not eql us_fixture
          end
        end
      end
    end
  end
end
