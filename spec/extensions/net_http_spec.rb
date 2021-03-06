require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Net::HTTP Extensions" do
  before(:all) do
    @orig_allow_net_connect = FakeWeb.allow_net_connect?
    FakeWeb.allow_net_connect = true
  end

  after(:all) do
    FakeWeb.allow_net_connect = @orig_allow_net_connect
  end

  before(:each) do
    @current_cassette = mock
    VCR.stub!(:current_cassette).and_return(@current_cassette)
    FakeWeb.clean_registry
  end

  describe 'a request that is not registered with FakeWeb' do
    it 'calls #store_recorded_response! on the current cassette' do
      recorded_response = VCR::RecordedResponse.new(:get, 'http://example.com:80/', :example_response)
      VCR::RecordedResponse.should_receive(:new).with(:get, 'http://example.com:80/', an_instance_of(Net::HTTPOK)).and_return(recorded_response)
      @current_cassette.should_receive(:store_recorded_response!).with(recorded_response)
      Net::HTTP.get(URI.parse('http://example.com'))
    end

    it 'calls #store_recorded_response! only once, even when Net::HTTP internally recursively calls #request' do
      @current_cassette.should_receive(:store_recorded_response!).once
      Net::HTTP.new('example.com', 80).post('/', nil)
    end

    it 'does not have an error if there is no current cassette' do
      VCR.stub!(:current_cassette).and_return(nil)
      lambda { Net::HTTP.get(URI.parse('http://example.com')) }.should_not raise_error
    end
  end

  describe 'a request that is registered with FakeWeb' do
    it 'does not call #store_recorded_response! on the current cassette' do
      FakeWeb.register_uri(:get, 'http://example.com', :body => 'example.com response')
      @current_cassette.should_not_receive(:store_recorded_response!)
      Net::HTTP.get(URI.parse('http://example.com'))
    end
  end
end