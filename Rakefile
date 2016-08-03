require 'octokit'
require_relative 'repos'
require_relative 'hey_there'

desc "checks X repo for any issues that need reminders, and pings if so"
task :hey do
  Octokit.configure do |c|
    c.login = ENV['GITHUB_USERNAME']
    c.password = ENV['GITHUB_PAT_OCTOKIT']
  end

  # check for repository input
  if ENV["repo"].class == String
    repo = ENV["repo"]
  else
    repo = Heythere.repository
  end

  # run hey_there
  begin
    Heythere.hey_there(repo = repo)
  rescue
    next
  end
end

desc "list env vars"
task :envs do
  puts 'repository: ' + Heythere.repository
  puts 'bot nickname: ' + Heythere.bot_nickname
  puts 'label target: ' + Heythere.label_target
  puts 'label assigned: ' + Heythere.label_assigned
  puts 'label review in: ' + Heythere.label_review_in
  puts 'pre deadline days: ' + Heythere.pre_deadline_days
  puts 'deadline days: ' + Heythere.deadline_days
  puts 'deadline every days: ' + Heythere.post_deadline_every_days
  puts 'remind after review days: ' + Heythere.post_review_in_days
  puts 'remind after review (toggle): ' + Heythere.post_review_toggle.to_s
end
