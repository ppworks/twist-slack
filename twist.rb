require 'bundler'
Bundler.require

track_keywords = ENV['TWITTER_TRACK_KEYWORDS']
ignore_users = (ENV['TWITTER_TRACK_IGNORE_USERS'] || '').split(/\s/)

options = {
  path:   '/1/statuses/filter.json',
  params: { track: track_keywords },
  oauth:  {
    consumer_key:    ENV['TWITTER_CONSUMER_KEY'],
    consumer_secret: ENV['TWITTER_CONSUMER_SECRET'],
    token:           ENV['TWITTER_OAUTH_TOKEN'],
    token_secret:    ENV['TWITTER_OAUTH_SECRET']
  }
}

EM.run do
  twitter_client = EM::Twitter::Client.connect(options)

  twitter_client.each do |result|
    result = JSON.parse(result)
    next if ignore_users.include?(result['user']['screen_name'])
    next if track_keywords.include?(result['user']['screen_name'])

    status_url = "https://twitter.com/#{result['user']['screen_name']}/status/#{result['id']}"
    slack = Slack::Notifier.new(ENV['SLACK_WEBHOOK'])
    slack.ping(status_url)
  end
end
