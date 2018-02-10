require 'date'
require 'faraday'
require 'multi_json'
require_relative 'github'
require_relative 'helpers'

# Travis API base url, using V3 API
# docs: https://developer.travis-ci.org/
$travis_base = 'https://api.travis-ci.org'

# setup Faraday connection
$travis_conn = Faraday.new(:url => $travis_base) do |f|
  # f.response :logger
  f.adapter  Faraday.default_adapter
end
$travis_conn.headers['Travis-API-Version'] = '3'
$travis_conn.headers['Content-Type'] = 'application/json'
$travis_conn.headers['User-Agent'] = 'faraday/%s rOpenSci' % Faraday::VERSION
$travis_conn.headers['Authorization'] = 'token ' + ENV['TRAVIS_ROPENSCIBOT_TOKEN']

class Faraday::Response
  def travis_raise
    if self.status > 202
      bod = MultiJson.load(self.body)
      raise '%s: %s; %s' % [self.status, self.to_hash[:url].to_s, bod['error_message']]
    end
  end  
end

# return: Hash of single repository
# e.g., travis_repo('17551975')
def travis_repo(x)
  x = $travis_conn.get 'repo/' + x
  x.travis_raise
  return MultiJson.load(x.body)
end

# return: Hash of repositories listed under ropenscibot Travis account
# e.g., travis_repos
def travis_repos
  x = $travis_conn.get 'owner/ropenscibot/repos'
  x.travis_raise
  return MultiJson.load(x.body)
end

# e.g.: travis_repos.travis_repo_id('ropenscibot/foobar3')
# return: string of '{repo id}'
class Hash
  def travis_repo_id(x)
    tmp = self["repositories"].select { |z| z['slug'].match(/#{x}/) }
    if tmp.length
      return tmp[0]['@href'].split('/').last
    else
      raise "repository in Travis not found"
    end
  end
end

# Check if Travis is running for a repo ID
# x: a Travis repo id
# return: Hash of single repository
# e.g., travis_running?('ropenscibot/foobar3')
def travis_running?(x)
  x = $travis_conn.get 'repo/%s/builds' % x.sub('/', '%2F')
  x.travis_raise
  state = MultiJson.load(x.body)["builds"][0]['state']
  return ["started", "running", "queued"].include? state
end

# return: Boolean
# e.g.: travis_sync
def travis_sync
  res = $travis_conn.post 'user/453045/sync'
  res.travis_raise
  res.success?
end

# return: Hash
# x: repo/{repo id} slug
# e.g.: travis_enable(x = '17551975')
def travis_enable(x)
  res = $travis_conn.post 'repo/' + x.to_s + '/activate'
  res.travis_raise
  res.success?
end

# return: Hash
# x: repo/{repo id} slug
# e.g.: travis_disable(x = '17551975')
def travis_disable(x)
  res = $travis_conn.post 'repo/' + x.to_s + '/deactivate'
  res.travis_raise
  res.success?
end


# return: Hash
# x: repo/{repo id} slug
# return: Boolean
# e.g.: travis_disable(x = '11710231')
def travis_trigger_build(x)
  res = $travis_conn.post 'repo/' + x.to_s + '/requests'
  res.travis_raise
  res.success?
end
