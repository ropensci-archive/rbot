require 'date'
require 'octokit'
require_relative 'helpers'
require_relative 'configuration'

module Heythere
  extend Configuration

  define_setting :repository, ENV['HEYTHERE_REPOSITORY']
  define_setting :bot_nickname, ENV['HEYTHERE_BOT_NICKNAME'] || ''
  define_setting :pre_deadline_days, ENV['HEYTHERE_PRE_DEADLINE_DAYS'] || '15'
  define_setting :deadline_days, ENV['HEYTHERE_DEADLINE_DAYS'] || '21'
  define_setting :post_deadline_every_days, ENV['HEYTHERE_POST_DEADLINE_EVERY_DAYS'] || '4'
  define_setting :post_review_in_days, ENV['HEYTHERE_POST_REVIEW_IN_DAYS'] || '14'
  define_setting :post_review_toggle, ENV['HEYTHERE_POST_REVIEW_TOGGLE'] || false
  define_setting :label_target, ENV['HEYTHERE_LABEL_TARGET'] || 'package'
  define_setting :label_assigned, ENV['HEYTHERE_LABEL_ASSIGNED'] || '3/reviewers-assigned'
  define_setting :label_review_in, ENV['HEYTHERE_LABEL_REVIEW_IN'] || '4/review-in-awaiting-changes'

  def self.hey_there(repo)
    if Heythere.bot_nickname.length != 0
      bot_name = sprintf("(%s)", Heythere.bot_nickname)
    end

    puts 'using repo ' + repo
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

        tags = x['labels'].map(&:name)
        if tags.has?('holding')
          puts sprintf('%s issue %s %s', repo, x['number'], 'on hold, skipping')
        else
          if tags.has?(Heythere.label_assigned)
            if !tags.has?(Heythere.label_review_in)
              puts sprintf('%s issue %s %s', repo, x['number'], 'editor-assigned and no reviews in, checking days since')
              # if editor-assigned and no reviews in, ping reviewers
              ## get issue comments
              iscomm = Octokit.issue_comments(repo, x['number'])
              tmp = iscomm.select { |a,b| a[:body].match('Reviewers:') }
              ## get date reviewers assigned
              rev_assgn = tmp[0][:created_at]
              ## if more than x days, ping, else stop
              if days_since(rev_assgn) < Heythere.deadline_days.to_i
                ## it's been < days since setting, don't ping the issue
                puts sprintf('%s issue %s %s', repo, x['number'], 'is within day limit, checking for predeadline ping')
                if days_since(rev_assgn) > Heythere.pre_deadline_days.to_i
                  ## get reviewer handles
                  ### get only reviewer handles that haven't submitted a review
                  #### gonna be messy because we don't have syntax in comment bodies that it is in fact a review
                  #### and not e.g., a question
                  revs = revs_not_reviewed(iscomm, tmp)
                  if revs.nil?
                    puts sprintf('%s issue %s - all reviewers appear to have submitted reviews, skipping', repo, x['number'])
                  else
                    ## check if reminders already sent, if so, skip, if not, send message
                    if already_pinged(iscomm, 'days, please get your review in by')
                      puts sprintf('%s issue %s - already pinged reviewers recently, skipping', repo, x['number'])
                    else
                      ## mention reviewers with message
                      mssg = sprintf("%s - hey there, it's been %s days, please get your review in by %s, thanks :smiley_cat: %s",
                        revs.join(' '), days_since(rev_assgn), days_plus_day(Heythere.deadline_days.to_i - days_since(rev_assgn)), bot_name)
                      ### add the comment
                      ff = Octokit.add_comment(repo, x['number'], mssg)
                      puts 'sent off ' + ff.length.to_s + 'comments'
                    end
                  end
                else
                  puts sprintf('%s issue %s %s', repo, x['number'], 'is less than half way, skipping')
                end
              else
                # post deadline for reviews in, just a reminder to get review in soon...
                ## get reviewer handles
                revs = revs_not_reviewed(iscomm, tmp)
                if revs.nil?
                  puts sprintf('%s issue %s - all reviewers appear to have submitted reviews, skipping', repo, x['number'])
                else
                  ## check if reminders already sent, if so, skip, if not, send message
                  if already_pinged_within_days(iscomm, Heythere.post_deadline_every_days, 'days, please get your review in soon')
                    puts sprintf('%s issue %s - already pinged reviewers recently, skipping', repo, x['number'])
                  else
                    ## mention reviewers with message
                    mssg = sprintf("%s - hey there, it's been %s days, please get your review in soon, thanks :smiley_cat: %s",
                      revs.join(' '), days_since(rev_assgn), bot_name)
                    ### add the comment
                    ff = Octokit.add_comment(repo, x['number'], mssg)
                    puts 'sent off ' + ff.length.to_s + 'comments'
                  end
                end
              end
            else
              # review in, check whether user wants to skip the post review notification
              if !Heythere.post_review_toggle
                puts sprintf('%s issue %s - chose to skip post review notification', repo, x['number'])
              else
                # review in, awaiting changes => ping if been more than x days
                ## find out when the label was added
                isevents = Octokit.issue_events(repo, x['number'])
                date_review_in = isevents.select { |x| x[:event].match('labeled') }.select { |z| z[:label][:name].match(Heythere.label_review_in) }.map(&:created_at)[0]
                if days_since(date_review_in) > Heythere.post_review_in_days.to_i
                  ## check first if any comments already submitted, if so skip
                  iscomm = Octokit.issue_comments(repo, x['number'])
                  if iscomm.map(&:body).select { |z| z.match('anything we can do to help') }.length == 0
                    ## mention submitter with message
                    ## get submitter handle
                    submitter = '@' + x[:user][:login]
                    ## construct message
                    mssg = sprintf("%s - hey there, it's been %s days since reviews were submitted - anything we can do to help? :smiley_cat: %s", submitter, days_since(date_review_in), bot_name)
                    ## send message
                    puts sprintf('sent off a comment to ask if theres anything we can do to help')
                  else
                    puts sprintf("%s issue %s %s reviews in, but we've already reminded the submitter")
                  end
                else
                  puts sprintf('%s issue %s %s reviews in, but less than %s, skipping', repo, x['number'], Heythere.post_review_in_days.to_i)
                end
              end
            end
          else
            # no editor assigned => skipping
            ## could add option to not skip here, but ping and say that an editor should be picked
            puts sprintf('%s issue %s %s', repo, x['number'], 'no editor assigned, skipping')
          end
        end
      end
    end
  end

end
