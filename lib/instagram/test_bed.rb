module Instagram
	module Configuration

		# creates a test bed layer in order to test your app with pre-defined responses 
		module TestBed 

			# stub requests 
			def activate_test_bed 
				require 'webmock'
				WebMock.allow_net_connect! 
				stub_get_access_token
				stub_get_media_item
				stub_get_media_popular
				stub_get_user_media_feed
				stub_get_user_recent_media
				stub_get_user_info
			end


			private 

			# Stubs -----
			def stub_get_access_token 
			  get_access_token_request = "https://api.instagram.com/oauth/access_token/" 
			  WebMock::API.stub_request(:post, get_access_token_request).
			    with(:body => WebMock::API.hash_including(:code => "test_bed")).
			    to_return(:status => 200, :body => fixture("test_bed_access_token.json"), :headers => {})

			  WebMock::API.stub_request(:post, get_access_token_request).
			    with(:body => WebMock::API.hash_including(:code => "test_bed_not_respond"))
			end

			def stub_get_media_item
				request = Instagram.endpoint + "media/18600493.json"
				WebMock::API.stub_request(:get, request).
					with(:query => {:access_token => 'test_bed_at'}).
		      to_return(:status => 200, :body => fixture("media.json"), :headers => {:content_type => "application/json; charset=utf-8"})
			end

			def stub_get_media_popular
				request = Instagram.endpoint + "media/popular.json"
				WebMock::API.stub_request(:get, request).
					with(:query => {:access_token => 'test_bed_at'}).
		      to_return(:status => 200, :body => fixture("media_popular.json"), :headers => {:content_type => "applicatimedia on/json; charset=utf-8"})
			end

			def stub_get_user_media_feed
				request = Instagram.endpoint + "users/self/feed.json"
				WebMock::API.stub_request(:get, request).
					with(:query => {:access_token => 'test_bed_at'}).
		      to_return(:status => 200, :body => fixture("user_media_feed.json"), :headers => {:content_type => "applicatimedia on/json; charset=utf-8"})
			end

			def stub_get_user_recent_media
				request = Instagram.endpoint + "users/self/media/recent.json"
				WebMock::API.stub_request(:get, request).
					with(:query => {:access_token => 'test_bed_at'}).
		      to_return(:status => 200, :body => fixture("recent_media.json"), :headers => {:content_type => "applicatimedia on/json; charset=utf-8"})
			end

			def stub_get_user_info
				request = Instagram.endpoint + "users/4.json"
				WebMock::API.stub_request(:get, request).
					with(:query => {:access_token => 'test_bed_at'}).
		      to_return(:status => 200, :body => fixture("mikeyk.json"), :headers => {:content_type => "applicatimedia on/json; charset=utf-8"})
			end


			# Fixtures -----
			def fixture_path
			  File.expand_path("../../../spec/fixtures", __FILE__)
			end

			def fixture(file)
			  File.new(fixture_path + '/' + file)
			end

		end
	end
end



