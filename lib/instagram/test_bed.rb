module Instagram
	module Configuration

		# creates a test bed layer in order to test your app with pre-defined responses 
		module TestBed 

			# stub requests 
			def activate_test_bed 
				require 'webmock'
				WebMock.allow_net_connect! 
				stub_get_access_token
			end

			private 
			# Stubs -----
			def stub_get_access_token 
			  get_access_token_request = "https://api.instagram.com/oauth/access_token/" 
			  WebMock::API.stub_request(:post, get_access_token_request).
			    with(:body => WebMock::API.hash_including(:code => "test_bed")).
			    to_return(:status => 200, :body => dry_run_fixture("test_bed_access_token.json"), :headers => {})
			end

			# Fixtures -----
			def dry_run_fixture_path
			  File.expand_path("../../../spec/fixtures", __FILE__)
			end

			def dry_run_fixture(file)
			  File.new(dry_run_fixture_path + '/' + file)
			end

		end
	end
end



