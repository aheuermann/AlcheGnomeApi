Twit = require 'twit'
async = require 'async'
_ = require 'underscore'

cache = require './RedisVanguard'

T = new Twit {
  consumer_key:         'Z2lf3HcjTwaOFmynyt5cgQ'
  consumer_secret:      'FRCfnAScX3Yg6YmcQmHKeoXJTRxZV82v69scKf4jCHQ'
  access_token:         '11726242-WOb8IRAMFmrO3hU6xPrk9I0n3iwG408VDWNXshAHa'
  access_token_secret:  'GXIkzXP5GMi4XNfBlJCOq9W5e1YPyFfOkHybRFQOSY4'
}

MAX_TWEETS = 320

getTweets = (method, q, callback) ->
  key = "tweets:#{method}:#{JSON.stringify(q)}"
  cache.get key, (err, results) ->
    if results
      callback err, results
    else
      all = []
      count = 4
      q.count = 100
      async.whilst( 
        -> count > 0
        (done) ->
          console.log "Twitter loop iteration #{count}"
          T.get method, q, (err, tweets) ->
            console.log "TwitterErr: #{JSON.stringify(err)}"if err
            tweets = tweets.statuses if tweets?.statuses
            if tweets and tweets.length > 0
              all = all.concat(tweets)
              q.max_id = _.last(tweets).id if tweets
              count--
            else 
              count = 0

            done(err)
        (err) ->
          if all.length > MAX_TWEETS
            all = all.splice 0, MAX_TWEETS

          console.log "Grabbed: #{all.length}"
          
          results = _.map(all, (t) -> 
            user = t.user
            t = _.pick t, ['text', 'id', 'created_at', 'retweet_count', 'favorite_count']
            t.id = "t:#{t.id}"
            t.user = {}
            t.user = _.extend t.user, _.pick(user, ['profile_image_url', 'screen_name', 'name', 'location'])
            t.alchemyText = t.text
            t
          )
          
          cache.set key, results
          callback err, results
      )

module.exports = 
  getTweets: getTweets