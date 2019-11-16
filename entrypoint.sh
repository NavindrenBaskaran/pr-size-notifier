#!/usr/bin/env ruby

require 'json'
require 'octokit'

webhook_event_payload = File.read(ENV['GITHUB_EVENT_PATH'])
webhook_event_payload_in_json = JSON.parse(webhook_event_payload)
repo_name = webhook_event_payload_in_json['repository']['full_name']

acceptable_pr_size = ENV['ACCEPTABLE_PR_SIZE'] || 10

github = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])

most_recent_commit_hash = webhook_event_payload_in_json['after']

opened_pull_requests = github.pull_requests(repo_name, state: 'open')

current_pull_request = opened_pull_requests.select { |opened_pull_request| opened_pull_request['head']['sha'] == most_recent_commit_hash.to_s }.last


if !current_pull_request
  puts 'No pull request with the given PR number.'
  exit(true)
end

pr_number = current_pull_request['number']
pr = github.pull_request(repo_name, pr_number, state: 'open')

total_addition_and_deletions = pr['additions'] + pr['deletions']
pr_comments = github.issue_comments(repo_name, pr_number)
github_bot_username = 'github-actions[bot]'
large_pr_comment = 'This pull request is big. We prefer smaller PRs whenever possible, as they are easier to review. Can this be split into a few smaller PRs?'

if pr_comments && pr_comments.select { |pr_comment| pr_comment['user']['login'] == github_bot_username && pr_comment['body'] ==  large_pr_comment }
  puts 'Already notified about the PR size.'
  exit(true)
end

if total_addition_and_deletions > acceptable_pr_size
  github.add_comment(repo_name, pr_number, comment)
end
