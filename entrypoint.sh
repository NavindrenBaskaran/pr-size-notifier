require 'octokit'

webhook_event_payload = ENV["GITHUB_EVENT_PATH"]

# github_client = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])

# pull_request = github_client

puts webhook_event_payload

