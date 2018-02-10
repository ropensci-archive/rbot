require 'octokit'
require_relative 'rbot_alternative'

desc "checks a github repo for any issues that have pkgs that need to be checked"
task :run do
  Octokit.configure do |c|
    c.login = ENV['GITHUB_USERNAME_RBOT']
    c.password = ENV['GITHUB_PAT_OCTOKIT_RBOT']
  end

  # check for repository input
  if ENV["repo"].class == String
    repo = ENV["repo"]
  else
    repo = Rbot.repository
  end

  # run bot
  begin
    Rbot.run_gp(repo = repo)
    Rbot.ping_issues(repo = repo)
  rescue
    next
  end
end

desc "run goodpractice as needed"
task :gp do
  Octokit.configure do |c|
    c.login = ENV['GITHUB_USERNAME_RBOT']
    c.password = ENV['GITHUB_PAT_OCTOKIT_RBOT']
  end

  # check for repository input
  if ENV["repo"].class == String
    repo = ENV["repo"]
  else
    repo = Rbot.repository
  end

  # run bot
  begin
    Rbot.run_gp(repo = repo)
  rescue
    next
  end
end

desc "ping issues as needed"
task :pi do
  Octokit.configure do |c|
    c.login = ENV['GITHUB_USERNAME_RBOT']
    c.password = ENV['GITHUB_PAT_OCTOKIT_RBOT']
  end

  # check for repository input
  if ENV["repo"].class == String
    repo = ENV["repo"]
  else
    repo = Rbot.repository
  end

  # run bot
  begin
    Rbot.ping_issues(repo = repo)
  rescue
    next
  end
end

desc "list env vars"
task :envs do
  puts 'repository: ' + Rbot.repository
  puts 'bot nickname: ' + Rbot.bot_nickname
end
