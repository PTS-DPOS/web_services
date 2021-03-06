== README

# Installation

1. This is a regular Ruby on Rails application, just follow Ruby on Rails installation instructions, e.g. this guide http://guides.rubyonrails.org/getting_started.html#installing-rails

2. The app uses mysql to store its data, so you need to install mysql before can you proceed to next step. After mysql is installed, edit config/database.yml and specify mysql connecton parameters.

3. After you have Ruby, mysql and Rails installed, type the following commands:

  $ cd faucet
  $ bundle
  $ rake db:create
  $ rake db:migrate

4. Install and launch pts command line client. (https://github.com/PTS-DPOS/PTS)


# Configuration

Go to config dir and copy bitshares-example.yml to bitshares.yml, edit bitshares.yml and specify required parameters.

In order to collect OAuth tokens, visit the following links and create applications/tokens for each provider:

### Google

https://console.developers.google.com

Redirect URI should be http://example.com/users/auth/google_oauth2/callback
Note, please make sure under "APIs" that you have the "Contacts API" and "Google+ API" enabled


### Facebook

https://developers.facebook.com/apps/

On Settings/Advanced tab enable Client OAuth Login end enter the following redirect URI:
http://example.com/users/auth/facebook/callback


### Twitter

https://apps.twitter.com


### LinkedIn

https://www.linkedin.com/secure/developer


### GitHub

https://github.com/settings/applications


### Reddit:

https://ssl.reddit.com/prefs/apps/

Note, redirect uri is required to contain full path, e.g. http://example.com/users/auth/reddit/callback


If you are planning to use referral codes, after you specified rpc port, user name and password, run the following command:

  $ rake db:seed

This will test rpc connection and populate assets table with the list of assetes retrieved from the blockchain.
