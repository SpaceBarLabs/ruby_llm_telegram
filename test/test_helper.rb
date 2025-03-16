ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "vcr"
require "webmock/minitest"

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock

  # Filter sensitive data
  config.filter_sensitive_data("<OPENROUTER_API_KEY>") do |interaction|
    if interaction.request.headers["Authorization"]&.first =~ /^Bearer\s+(.+)$/
      $1
    else
      Rails.application.credentials.openrouter_api_key
    end
  end

  config.filter_sensitive_data("<APP_URL>") { Rails.application.credentials.app_url }

  # Configure how VCR matches requests
  config.default_cassette_options = {
    record: :once,
    match_requests_on: [ :method, :uri, :body ],
    allow_playback_repeats: true,
    preserve_exact_body_bytes: true
  }

  # Don't allow any HTTP connections when a cassette doesn't exist
  config.allow_http_connections_when_no_cassette = false
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
