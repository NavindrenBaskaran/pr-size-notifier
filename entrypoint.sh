#!/usr/bin/env ruby

require 'json'
require 'octokit'

webhook_event_payload = File.read(ENV["GITHUB_EVENT_PATH"])
webhook_event_payload_in_json = JSON.parse(webhook_event_payload)

github = Octokit::Client.new(access_token: "c4ccfd07929f2501a3e052aed398ba8c16df9908")

most_recent_commit_hash = webhook_event_payload_in_json["after"]

opened_pull_requests = github.pull_requests("NavindrenBaskaran/sign_up", state: 'open')

current_pull_request = opened_pull_requests.select { |opened_pull_request| opened_pull_request["head"]["sha"] == most_recent_commit_hash }.last

if current_pull_request.present?
  pr_number = current_pull_request["number"]
  github.add_comment("NavindrenBaskaran/sign_up", pr_number, "Done!")
end

