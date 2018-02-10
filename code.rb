require 'date'
require 'octokit'
require 'faraday'
require 'faraday_middleware'
require 'multi_json'
require_relative 'helpers'
require_relative 'configuration'
require_relative 'travis'

module Rbot
  extend Configuration

  define_setting :repository, ENV['RBOT_REPOSITORY']
  define_setting :bot_nickname, ENV['RBOT_BOT_NICKNAME'] || ''
  define_setting :label_target, ENV['RBOT_LABEL_TARGET'] || 'package'

  # return: Octokit class (Sawyer::Resource)
  def self.fork(repo)
    begin
      forked = Octokit.fork(repo)
    rescue Exception => e
      raise e
    end

    return forked
  end

  # return: Hash of repositories listed under ropenscibot Travis account
  def self.travis_repos
    x = $conn.get 'owner/ropenscibot/repos'
    return MultiJson.load(x.body)
  end

  # return: Hash
  def self.travis_enable(repo)
    x = $conn.get 'repo/%s' % forked.full_name
    $conn.get 'repo/%s/activate' % repo.id
    # Travis.session.user.sync
    # x = Travis::Repository.find(repo)
    # x.enable
  end

  # return: Hash
  def self.travis_prep(repo)
    begin
      forked = Travis(repo)
    rescue Exception => e
      raise e
    end

    # $conn = Faraday.new(:url => $tbase) do |f|
    #   f.adapter  Faraday.default_adapter
    # end
    $conn.headers['Travis-API-Version'] = '3'
    $conn.headers['User-Agent'] = 'faraday/%s rOpenSci' % Faraday::VERSION
    $conn.headers['Authorization'] = 'token ' + ENV['TRAVIS_TOKEN']
    # $conn.headers[:accept] = 'application/vnd.travis-ci.2+json'
    # $conn.headers['Authorization'] = 'token ' + ENV['TRAVIS_TOKEN']

    def get_repo(x)
      res = $conn.get 'repos/' + ENV[x]
      xx = MultiJson.load(res.body)
      if xx.keys[0] == 'file'
        xx = nil
      end
      return xx
    end
  end

end
