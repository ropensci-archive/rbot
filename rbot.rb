require 'date'
require 'octokit'
require_relative 'helpers'
require_relative 'travis'
require_relative 'github'
require_relative 'utils'
require_relative 'serverutils'
require_relative 'configuration'
require_relative 'travis_strings'

module Rbot
  extend Configuration

  define_setting :repository, ENV['RBOT_REPOSITORY']
  define_setting :bot_nickname, ENV['RBOT_BOT_NICKNAME'] || ''
  define_setting :label_target, ENV['RBOT_LABEL_TARGET'] || 'package'
  define_setting :travis_file_missing, $travis_file_missing
  define_setting :travis_file_adding, $travis_file_adding

  # run goodpractice: fork repos, run on travis, deploy output to S3
  def self.run_gp(repo, force_travis)
    if Rbot.bot_nickname.length != 0
      bot_name = sprintf("(%s)", Rbot.bot_nickname)
    end

    # repo = Rbot.repository

    puts 'using repo "' + repo + '"'
    begin
      is = Octokit.issues repo, :per_page => 100;
    rescue Exception => e
      puts sprintf("Encountered an error with %s", repo)
      puts e
    end

    puts is.length.to_s + ' issues found'

    if is.length == 0
      raise 'no issues found'
    else
      # for each issue, run through labels and days since events
      is.each do |x|
        # get meta info
        info = x.to_h.get_info
        puts "[%s]: starting" % info[:number]

        # - get github repo link
        puts "[%s]: get github repository link" % info[:number]
        gh_repo = x.to_h.github_repo_link.owner_repo

        # - fork repo to ropenscibot account
        puts "[%s]: fork repo to ropenscibot" % info[:number]
        fked = github_fork(gh_repo);
        
        #- insert necessary goodpractice stuff
        puts "[%s]: update travis file or add one" % info[:number]
        fked.has_travis(info[:number], force_travis)

        # - run check
        ## get Travis repo id
        puts "[%s]: enable on Travis and trigger build" % info[:number]
        x = travis_repos.travis_repo_id(fked[:full_name]) 
        ## enable on Travis
        travis_enable(x)
        ## trigger Travis build (if not already trigged by adding/modifying travis file)
        travis_trigger_build(x) unless travis_running?(fked[:full_name])

        puts "[%s]: done\n\n" % info[:number]
      end
    end
  end

  # check issues and ping as needed
  def self.ping_issues(repo)
    if Rbot.bot_nickname.length != 0
      bot_name = sprintf("(%s)", Rbot.bot_nickname)
    end

    puts 'using repo "' + repo + '"'
    begin
      is = Octokit.issues repo, :per_page => 100;
    rescue Exception => e
      puts sprintf("Encountered an error with %s", repo)
      puts e
    end

    puts is.length.to_s + ' issues found'

    if is.length == 0
      raise 'no issues found'
    else
      # remove issues that aren't packages
      is = is.only_packages;

      if !is.length
        raise "skipping all; no issues with '%s' label" % Rbot.label_target
      else 
        # for each issue, run through labels and days since events
        is.each do |x|
          # get meta info
          info = x.to_h.get_info

          # - get github repo link
          gh_repo = x.to_h.github_repo_link.owner_repo

          # - check for any new build output in S3
          #- if no new output, skip
          #- if new output, next step to ping issue with output
          #- how are we going to determine if we already pinged the issue?
          #-   could just scan comments in the onboarding issue for any from ropenscibot + with specific words 'rOpenSci Bot Report'

          if has_package_label?(info[:number], Rbot.label_target) # probably replace w/ checking for "0/editor" label?
            if do_we_need_to_ping_issue_with_gp_report?(info[:number])
              if x.is_there_a_gp_report_in_s3? 
                url = fetch_s3("<package>")
                report = read_gp_summary(url)
                # - ping issue with summary and link to output
                ping_repo(Rbot.repository, info[:number], report)
                # ping_repo("sckott/foobar3", 1, txt)
                puts 'pinged issue %s with gp report' % info[:number]
              else
                puts 'skipping issue %s - gp report not ready yet' % info[:number]
              end
            else 
              puts 'skipping issue %s - already pinged or ??' % info[:number]
            end
          else
            puts 'skipping issue %s - has no package label' % info[:number]
          end

        end
      end
    end
  end

end
