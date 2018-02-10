require 'octokit'
require_relative 'rbot'

class Bot < Thor
  desc "gp", "run goodpractice as needed"
  long_desc <<-LONGDESC
    `thor bot:gp` runs goodpractice across issues for a 
    repository.

    You can optionally specify to force update of the 
    .travis.yml file.

    Steps are: grab github repository info from github api, 
    fork repository to the `ropenscibot` GitHub account, 
    insert fields into the .travis.yml file (if needed),
    then enable on Travis under `ropenscibot` account 
    (if not already), then trigger a build on Travis.
    After a successful build, two goodpractice output files 
    are deployed to Amazon S3 bucket.

    Settings:\n
    GitHub setup: We use ENV vars `GITHUB_USERNAME_RBOT` and `GITHUB_PAT_OCTOKIT_RBOT`\n
    Target GitHub repository: from ENV var `RBOT_REPOSITORY`\n
    Bot nickname: `RBOT_BOT_NICKNAME` ENV var\n
    Target GitHub issue lable: `RBOT_LABEL_TARGET` ENV var\n

    
    # by default force=false
    \x5$ thor bot:gp


 
    # set force=true
    \x5$ thor bot:gp --force-travis-file
  LONGDESC
  option :force_travis_file, :type => :boolean
  def gp
    Octokit.configure do |c|
      c.login = ENV['GITHUB_USERNAME_RBOT']
      c.password = ENV['GITHUB_PAT_OCTOKIT_RBOT']
    end

    begin
      Rbot.run_gp(repo = Rbot.repository, 
        force_travis = options[:force_travis_file])
    rescue Exception => e
      raise e
    end
  end

  desc "envs", "list env vars"
  def envs
    puts 'repository: ' + Rbot.repository
    puts 'bot nickname: ' + Rbot.bot_nickname
    puts 'label target: ' + Rbot.label_target
    puts 'github username: ' + ENV['GITHUB_USERNAME_RBOT']
    puts 'github username: ' + '<secret>'
  end
end

