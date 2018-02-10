# deals with any github related activities
require 'date'
require 'octokit'
require 'faraday'
require 'multi_json'
require_relative 'helpers'

# Github API base url, using V3 API
# docs: https://developer.github.com/v3
$github_base = 'https://api.github.com'

# setup Faraday connection
$github_conn = Faraday.new(:url => $github_base) do |f|
  # f.response :logger
  f.adapter  Faraday.default_adapter
end
$github_conn.headers['Accept'] = 'application/vnd.github.v3+json'
$github_conn.headers['Content-Type'] = 'application/json'
$github_conn.headers['User-Agent'] = 'faraday/%s rOpenSci' % Faraday::VERSION
$github_conn.headers['Authorization'] = 'token ' + ENV['GITHUB_PAT_OCTOKIT_RBOT']

# return: Octokit class (Sawyer::Resource)
# repo: owner/repo slug
def github_fork(repo)
  begin
    forked = Octokit.fork(repo)
  rescue Exception => e
    raise e
  end

  return forked
end


# handle Github API errors
class Faraday::Response
  def github_raise
    if self.status > 201
      bod = MultiJson.load(self.body)
      raise '%s: %s; %s %s' % [self.status, self.to_hash[:url].to_s, bod['message'], bod['documentation_url']]
    end
  end  
end


# create a file
# repo: owner/repo slug
# path: file path in the repo
# message: string, commit message
# contents: string of contents, will be base64 encoded internally 
# return: hash
# e.g., github_create_file(repo="ropenscibot/foobar4", path=".travis.yml", message="added a .travis.yml file", contents = Rbot.travis_file_missing)
def github_create_file(repo, path, message, contents)
  contents = Base64.encode64 contents
  body = { 
    "message" => message, 
    "commiter" => { "name" => "Scott Chamberlain", "email" => "myrmecocystus@gmail.com" },
    "content" => contents
  }
  url_path = '/repos/%s/contents/%s' % [repo, path]
  res = $github_conn.put url_path, MultiJson.dump(body)
  res.github_raise
  MultiJson.load(res.body)
end

# update a file
# repo: owner/repo slug
# path: file path in the repo
# message: string, commit message
# contents: string of contents, will be base64 encoded internally 
# sha: The blob SHA of the file being replaced.
# return: hash
# e.g., github_create_file(repo="ropenscibot/foobar4", path=".travis.yml", 
#    message="added a .travis.yml file", contents = Rbot.travis_file_missing, sha = "237234234234")
def github_update_file(repo, path, message, contents, sha)
  contents = Base64.encode64 contents
  body = { 
    "message" => message, 
    "commiter" => { "name" => "Scott Chamberlain", "email" => "myrmecocystus@gmail.com" },
    "content" => contents,
    "sha" => sha
  }
  url_path = '/repos/%s/contents/%s' % [repo, path]
  res = $github_conn.put url_path, MultiJson.dump(body)
  res.github_raise
  MultiJson.load(res.body)
end




# Get comments for an issue
# issue: issue number
# repo: owner/repo string
# return: hash
# e.g., github_issue_comments(5)
def github_issue_comments(issue, repo = Rbot.repository)
  Octokit.issue_comments(repo, issue.to_s)
end

# Check if we've already pinged the issue with the gp report
# issue: issue number
# repo: owner/repo string
# return: hash
# e.g., do_we_need_to_ping_issue_with_gp_report?(issue = 1)
def do_we_need_to_ping_issue_with_gp_report?(issue)
  comms = github_issue_comments(issue);
  logins = comms.map { |z| z[:user][:login] }
  if !logins.include? 'ropenscibot'
    return true
  else

  end
end

# Check if an issue has a certain label
# issue: issue number
# repo: owner/repo string
# return: hash
# e.g., has_package_label?(issue = 1, label = "package")
def has_package_label?(issue, label, repo = Rbot.repository)
  tmp = Octokit.issue(repo, issue.to_s);
  if tmp[:labels].length
    return tmp[:labels].map(&:name).include? label
  else
    return false
  end
end

# Ping an issue with a comment
# repo: owner/repo string
# issue: issue number
# report: a string of text, in this case the goodpractice report
# return: hash
# e.g., ping_repo("sckott/foobar3", 1, "howdy neighbor")
def ping_repo(repo, issue, report)
  mssg = "## :robot: rOpenSci Bot Report 

We ran `goodpractice` on your package and here are the results. Address these along with comments from your reviewers.

<details> <summary><strong>Goodpractice Report (click to expand)</strong></summary>

```
%s
```
</details>" % report
  Octokit.add_comment(repo, issue, mssg)
end

