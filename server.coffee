Twit = require 'twit'
AlchemyAPI = require('alchemy-api')
async = require 'async'
_ = require 'underscore'
express = require 'express'

app = express()

app.all('*', (req, res, next) ->
  res.header "Access-Control-Allow-Origin", "*"
  res.header "Access-Control-Allow-Headers", "X-Requested-With"
  #'Access-Control-Allow-Methods', 'PUT, GET, POST, DELETE, OPTIONS'
  next()
)

T = new Twit {
  consumer_key:         'Z2lf3HcjTwaOFmynyt5cgQ'
  consumer_secret:      'FRCfnAScX3Yg6YmcQmHKeoXJTRxZV82v69scKf4jCHQ'
  access_token:         '11726242-WOb8IRAMFmrO3hU6xPrk9I0n3iwG408VDWNXshAHa'
  access_token_secret:  'GXIkzXP5GMi4XNfBlJCOq9W5e1YPyFfOkHybRFQOSY4'
}

alchemy = new AlchemyAPI('48d4b10b0009b09a9480bf64609620ff69c42dac')

app.get '/:user', (req, res) ->
  T.get 'statuses/user_timeline', {screen_name: req.params.user} , (err, tweets) ->
    getSentiment = (tweet, done) ->
      if tweet?.text
        alchemy.sentiment tweet.text, {}, (err, response) ->
          tweet.sentiment = response.docSentiment
          done()
      else 
        done() 
    if tweets and tweets?.length > 0
      async.eachLimit tweets, 5, getSentiment, (err) ->
        res.send _.map(tweets, (t) -> _.pick t, ['text', 'sentiment'])
    else
      res.send "No tweets for \"#{req.params.user}\""
port = process?.env?.PORT || 3000
app.listen port
console.log "listening #{port}"
