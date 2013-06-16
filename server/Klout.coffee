Klout = require "node_klout"

klout = new Klout("fkysp67c8py9c84abgfbrqt7", "json", "v2")

cache = require './RedisVanguard'

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
          if err
            console.log "KloutError: #{JSON.stringify(err)}"
            score = Math.floor(Math.random()*80)
            cache.set(key, score) if res.score
            callback(null, score) if callback
          else
            klout.getUserScore kloutUser.id, (err, res) ->
              if err
                console.log "Klout: #{JSON.stringify(err)}"
                score = Math.floor(Math.random()*80)
                cache.set(key, score) if res.score
                callback(null, score) if callback
              else
                #console.log "#{username} -> #{JSON.stringify(res.score)}"
                cache.set(key, res.score) if res.score
                callback(err, res.score) if callback

module.exports =
  getKloutScore: getKloutScore