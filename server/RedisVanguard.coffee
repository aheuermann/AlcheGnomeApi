
getConnection = (redis) ->
  client = client || redis.createClient() 
  console.log "Redisurl:#{process.env.REDISCLOUD_URL}"
  if process.env.REDISTOGO_URL
    console.log "using redis cloud"
    redisURL = require("url")..parse(process.env.REDISTOGO_URL)
    console.log JSON.stringify(redisURL)
    client = require('redis').createClient(redisURL.port, redisURL.hostname)
    client.auth(redisURL.auth.split(":")[1])
    return c
  else
    console.log "straight client"
    c = redis.createClient()
    return c

class RedisVanguard
  constructor: ->
    @client = getConnection redis

  set: (key, value) ->
    console.log "set:#{key}--#{value}"
    @client.set key, value
  
  get: (key, callback) ->
    @client.get key, (err, result) ->
      if err
        callback err
      else
        console.log "get:#{key}--#{result}"
        #result = JSON.parse(result) if result
        callback null, result


module.exports = new RedisVanguard()