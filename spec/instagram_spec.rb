require File.expand_path('../spec_helper', __FILE__)

describe Instagram do
  after do
    Instagram.reset
  end

  context "when delegating to a client" do

     before do
       stub_get("users/self/feed.json").
         to_return(:body => fixture("user_media_feed.json"), :headers => {:content_type => "application/json; charset=utf-8"})
     end

     it "should get the correct resource" do
       Instagram.user_media_feed()
       a_get("users/self/feed.json").should have_been_made
     end

     it "should return the same results as a client" do
       Instagram.user_media_feed().should == Instagram::Client.new.user_media_feed()
     end

   end

  describe ".client" do
    it "should be a Instagram::Client" do
      Instagram.client.should be_a Instagram::Client
    end
  end

  describe ".adapter" do
    it "should return the default adapter" do
      Instagram.adapter.should == Instagram::Configuration::DEFAULT_ADAPTER
    end
  end

  describe ".adapter=" do
    it "should set the adapter" do
      Instagram.adapter = :typhoeus
      Instagram.adapter.should == :typhoeus
    end
  end

  describe ".endpoint" do
    it "should return the default endpoint" do
      Instagram.endpoint.should == Instagram::Configuration::DEFAULT_ENDPOINT
    end
  end

  describe ".endpoint=" do
    it "should set the endpoint" do
      Instagram.endpoint = 'http://tumblr.com'
      Instagram.endpoint.should == 'http://tumblr.com'
    end
  end

  describe ".format" do
    it "should return the default format" do
      Instagram.format.should == Instagram::Configuration::DEFAULT_FORMAT
    end
  end

  describe ".format=" do
    it "should set the format" do
      Instagram.format = 'xml'
      Instagram.format.should == 'xml'
    end
  end

  describe ".user_agent" do
    it "should return the default user agent" do
      Instagram.user_agent.should == Instagram::Configuration::DEFAULT_USER_AGENT
    end
  end

  describe ".user_agent=" do
    it "should set the user_agent" do
      Instagram.user_agent = 'Custom User Agent'
      Instagram.user_agent.should == 'Custom User Agent'
    end
  end

  describe ".activate_test_bed" do
    before do 
      Instagram.activate_test_bed
    end
    let(:code) { 'test_bed' }
    let(:access_token) {'test_bed_at'}

    it "should stub '.get_access_token' when with the specific parameter 'code'=code" do
      response = Instagram.get_access_token(code, 
                          :redirect_uri => "http://localhost:4567/oauth/callback")
      response.access_token.should == "test_bed_at"
      response.user.username.should == "steookk"        
    end

    it "should allow any other request to connect to the network" do 
      lambda { Instagram.get_access_token('other_code', 
                          :redirect_uri => "http://localhost:4567/oauth/callback")}
              .should raise_error(Instagram::BadRequest)
      lambda { Instagram.media_popular() }
              .should raise_error(Instagram::BadRequest)              
    end
  end
  #aggiungere test su test_bed key e creazione metodi stub lo metto qui oppure dentro 
  #ad api_spec e i vari metodi di client? 

  describe ".configure" do

    Instagram::Configuration::VALID_OPTIONS_KEYS.each do |key|

      it "should set the #{key}" do
        Instagram.configure do |config|
          config.send("#{key}=", key)
          Instagram.send(key).should == key
        end
      end
    end
  end
end
