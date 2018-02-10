require 's3'
require 'faraday'
require 'multi_json'
require 'yaml'

$s3client = S3::Service.new(
	:access_key_id => ENV['AWS_ACCESS_KEY_ID_ROPENSCI_BOT'],
	:secret_access_key => ENV['AWS_ACCESS_KEY_SECRET_ROPENSCI_BOT']
)

# package: package name
# e.g. fetch_s3(package = 'foobar3')
# return: temporary url, with 1 hr expire time
def fetch_s3(package)
	bucket = $s3client.bucket("rogoodpractice")
	
	# get all objects
  obs = bucket.objects;
  
  # pull out those matching package name
  obs = obs.select { |a| a.key.match(/#{package}/) };

  # pull out those with .txt files
  obstxt = obs.select { |a| a.key.match(/\.txt/) }

  # pull out latest file by timestamp
	target = obstxt.max_by { |a| a.last_modified }

	# get URL
	target.temporary_url
end

# read goodpractice summary from a temporary url
# return: string of goodpractice summary
def read_gp_summary(url)
	cn = Faraday.new(:url => url) do |f|
  	f.adapter  Faraday.default_adapter
	end
	txt = cn.get.body.gsub! "\\n", "\n"
	return txt
end

class Hash
	def github_repo_link
		self[:body].scan(/http[s]?:\/\/github.com\/[0-9A-Za-z-]+\/[0-9A-Za-z]+/)[0]
	end
end

class String
	def owner_repo
		self.sub(/https:\/\/github\.com\//, '')
	end
end

class	Sawyer::Resource
	def has_travis(issue, force)
		repo = self[:full_name]

		begin
			res = Octokit.contents repo, path:".travis.yml"
		rescue Exception => e
			res = nil
		end

		if res.nil?
	    puts "[%s]: adding a travis file" % issue
			begin
				github_create_file(repo, ".travis.yml", "added a .travis.yml file", Rbot.travis_file_missing)
	    rescue Exception => e
	      puts e
	    end
		else
			puts "[%s]: travis file found" % issue
			remote_yml = YAML.parse Base64.decode64 res.content;
			local_yml = YAML.parse Rbot.travis_file_adding;
			bools = local_yml.to_ruby.keys.map { |x| remote_yml.to_ruby.keys.include? x }
			if bools.all? && !force
				puts "[%s]: skipping, travis file already has necessary information" % issue
			else
				begin
					puts "[%s]: updating travis file" % issue
					# merge two yamls
					ryr = remote_yml.to_ruby
					lyr = local_yml.to_ruby
					ryr.merge! lyr
					# send update
					tmp = github_update_file(repo, ".travis.yml", "modified the .travis.yml file", ryr.to_yaml, res[:sha])
		    rescue Exception => e
		      puts e
		    end
			end
		end
	end
end

class	String
	def travis_on
		Travis.access_token = ENV['TRAVIS_TOKEN_RBOT']
		z = Travis::Repository.find(self)
    z.enable
	end
end

class String
	def forkit
		Octokit.fork(self)
	end
end
