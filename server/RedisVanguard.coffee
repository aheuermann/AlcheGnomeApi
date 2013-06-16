redis = require 'redis'

getConnection = (redis) ->
  client = client || redis.createClient() 
  console.log "Redisurl:#{process.env.REDISCLOUD_URL}"
  if process.env.REDISCLOUD_URL
    console.log "using redis cloud"
    r = require("url").parse(process.env.REDISCLOUD_URL)
    c = redis.createClient(r.port, r.hostname, {no_ready_check: true})
    c.auth(r.auth.split(":")[1])
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