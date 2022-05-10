rbot
====

Heroku robot to check R packages submitted to rOpenSci.

## what it does

* check if any new submissions 
    * new submission
        * has `package` tag
            * build
    * 

## tasks

* determine when a pkg has been submitted
* fork a repo && create new repo in our account
* add any files necessary to our fork, e.g., .travis.yml file
* run all our checkers on our fork on Travis
* collect results from Travis
* store result in S3
* ping onboarding issue with results/problems

## Install

```
git clone git@github.com:ropenscilabs/rbot.git
cd rbot
```

## Setup

Create the app (use a different name, of course)

```
heroku apps:create ropensci-rbot
```

Create a GitHub personal access token just for this application. You'll need to set a env var for your username and the token. We read these in the app.

```
heroku config:add RBOT_REPOSITORY=<github-repository> (like `owner/repo`)
heroku config:add GITHUB_USERNAME=<github-user>
heroku config:add GITHUB_PAT_OCTOKIT=<github-pat-for-octokit>
heroku config:add RBOT_BOT_NICKNAME=<string>
```

Push your app to Heroku

```
git push heroku master
```

Add the scheduler to your heroku app

```
heroku addons:create scheduler:standard
heroku addons:open scheduler
```

Add the task ```rake do``` to your heroku scheduler and set to whatever schedule you want.


## Usage

If you have your repo in an env var as above, run the rake task `do`

```
rake do
```

If not, then pass the repo to `do` like

```
rake do repo=owner/repo
```

## Env vars

Non-secret env vars with what we use in parens, then explanation. The values in parens are the defaults as well.

* `RBOT_REPOSITORY` - no default (of the form `owner/repo`)
* `GITHUB_USERNAME` - no default
* `GITHUB_PAT_OCTOKIT` - no default
* `RBOT_LABEL_TARGET` - (`package`) - which issues to consider (others are ignored)
* `RBOT_BOT_NICKNAME` - no default - bot nickname

## Rake tasks

* rake do - check a package
* rake envs - lists all the env vars you've set. if you're using heroku, and you've set env vars there, you could also do `heroku config`
