Klout = require "node_klout"

klout = new Klout("5u7zsbnt6mbme9zn395nygem", "json", "v2")

cache = require './redisVanguard'

getKloutScore= (username, callback) ->
  if not username
    callback null, null
  else
    key = "alchemy:#{username}"
    cache.get key, (err, result) ->
      if result
        #console.log "CACHE: #{username} -> #{cache[username]}"
        callback null, result
      else
        #console.log "u:#{username}"
        klout.getKloutIdentity username, (err, kloutUser) ->
          klout.getUserScore kloutUser.id, (err, res) ->
            #console.log "#{username} -> #{JSON.stringify(res.score)}"
            cache.set(key, res.score) if res.score
            callback(err, res.score) if callback

module.exports =
  getKloutScore: getKloutScore