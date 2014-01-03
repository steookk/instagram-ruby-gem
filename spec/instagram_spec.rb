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
    before :each do 
      Instagram.activate_test_bed  #this stubs specific requests
      @access_token = 'test_bed_at'
    end
    let!(:client) { Instagram::Client.new(:client_id => 'CID', :client_secret => 'CS', :access_token => @access_token) }

    describe "'.get_access_token' for app testing" do    
      context "when code='test_bed'" do
        before :each do
          @response = Instagram.get_access_token('test_bed', 
                              :redirect_uri => "http://localhost:4567/oauth/callback")
        end

        it "should stub the post request" do
          a_request(:post, 'https://api.instagram.com/oauth/access_token/').
            should have_been_made
        end

        it "should return a specific access_token and user defined as a fixture" do 
          @response.access_token.should == "test_bed_at"
          @response.user.username.should == "steookk"  
        end     
      end

      context "when code='test_bed_not_respond'" do
        before :each do 
          @response = Instagram.get_access_token('test_bed_not_respond', 
                                        :redirect_uri => "http://localhost:4567/oauth/callback")
        end

        it "should stub the post request" do
          a_request(:post, 'https://api.instagram.com/oauth/access_token/').
            should have_been_made
        end

        it "should not respond in order to simulate a network or Instagram problem" do
          @response.should be nil 
        end
      end

      context "when code=anything else" do
        it "should allow the normal network request" do 
          lambda { Instagram.get_access_token('other_code', 
                                        :redirect_uri => "http://localhost:4567/oauth/callback")}
                  .should raise_error(Instagram::BadRequest)
        end
      end
    end

    describe "'.media_item(media_id)' when access_token=test_bed_at and media_id=18600493" do
      before :each do 
        @media_id = "18600493"
        @response = client.media_item(@media_id)
      end

      it "should stub the specific resource with media_id=18600493" do
        a_get("media/#{@media_id}.json").
          with(:query => {:access_token => @access_token}).
          should have_been_made
      end

      it "should not stub any other resource" do 
        lambda { client.media_item("1233434") }
                .should raise_error(Instagram::BadRequest) 
      end

      it "should return the same media item defined as a fixture and used for specs" do 
        @response.id.should == @media_id
        @response.user.username.should == "mikeyk"
      end
    end

    describe "'.media_popular' when access_token=test_bed_at" do
      before :each do 
        @response = client.media_popular
      end

      it "should stub the get request" do
        a_get("media/popular.json").
          with(:query => {:access_token => @access_token}).
          should have_been_made
      end

      it "should return the same media_popular fixture used for specs" do 
        @response.first.user.username.should == "iam_ess"
      end
    end

    describe "'.user_media_feed' when access_token=test_bed_at" do
      before :each do 
        @response = client.user_media_feed
      end

      it "should stub the get request" do
        a_get("users/self/feed.json").
          with(:query => {:access_token => @access_token}).
          should have_been_made
      end

      it "should return the same user's feed fixture used for specs" do 
        @response.first.user.username.should == "gaia_ga"
      end
    end

    describe "'.user_recent_media' when access_token=test_bed_at" do
      before :each do 
        @response = client.user_recent_media
      end

      it "should stub the self recent media" do
        a_get("users/self/media/recent.json").
          with(:query => {:access_token => @access_token}).
          should have_been_made
      end

      it "should not stub any other resource" do 
        lambda { client.user_recent_media("1233434") }
                .should raise_error(Instagram::BadRequest) 
      end

      it "should return the same media item defined as a fixture and used for specs" do 
        @response.first.user.username.should == "steookk"
      end
    end

    describe "'.user' when access_token=test_bed_at" do
      before :each do 
        @response = client.user('4')
      end

      it "should stub the user with id = 4" do
        a_get("users/4.json").
          with(:query => {:access_token => @access_token}).
          should have_been_made
      end

      it "should not stub any other resource" do 
        lambda { client.user("123") }
                .should raise_error(Instagram::BadRequest) 
      end

      it "should return the same media item defined as a fixture and used for specs" do 
        @response.username.should == "mikeyk"
      end
    end
  end


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
