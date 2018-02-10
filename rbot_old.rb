require 'date'
require 'octokit'
require_relative 'helpers'
require_relative 'utils'
require_relative 'configuration'

module Rbot
  extend Configuration

  define_setting :repository, ENV['RBOT_REPOSITORY']
  define_setting :bot_nickname, ENV['RBOT_BOT_NICKNAME'] || ''
  define_setting :label_target, ENV['RBOT_LABEL_TARGET'] || 'package'
  define_setting :travis_file, '
  language: r
  sudo: false
  cache: packages
  '

  def self.bot(repo)
    if Rbot.bot_nickname.length != 0
      bot_name = sprintf("(%s)", Rbot.bot_nickname)
    end

    puts 'using repo "' + repo + '"'
    begin
      is = Octokit.issues repo, :per_page => 100
    rescue Exception => e
      puts sprintf("Encountered an error with %s", repo)
      puts e
    end

    puts is.length.to_s + ' issues found'

    if is.length == 0
      raise 'no issues found'
    else
      # remove issues that aren't packages
      is = is.only_packages

      # for each issue, run through labels and days since events
      is.each do |x|
        info = x.to_h.get_info
        # - get github repo link
        gh_repo = x.to_h.github_repo_link.owner_repo

        # - fork repo to bot acct
        forked = gh_repo.forkit

        # - check if repo has a .travis.yml file - if not, put one in there
        forked.to_h.has_travis

        # - setup travis
        gh_repo.travis_on

        # - trigger travis build - not made yet
        gh_repo.travis_build

        # - collect build output - not made yet
        # - send output to Amazon S3 - not made yet
        # - make summary of output - not made yet
        # - ping issue with summary and link to output - not made yet
      end
    end
  end

end
