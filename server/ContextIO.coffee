ContextIO = require 'contextio'
_ = require 'underscore'
async = require 'async'

ctxioClient = new ContextIO.Client({
  key: "hh0jn0bl" #fake email account
  secret: "Q7aUikjvJMd8bJEY"
})

cache =
  messages: {}

getMessage = (message, done) ->
  if cache[message.id]
    done() 
  else
    ctxioClient.accounts('51bd21a98c157f583f2183d6').messages(message.id).body().get (err, resp) ->
      if err
        done err
      else
        m = _.find resp.body, (m) -> m.type is 'text/plain'
        message.text = m.content
        done err

getMessages = (done) ->
  ctxioClient.accounts('51bd21a98c157f583f2183d6').messages().get (err, resp) ->
    messages = _.map(resp.body, (m) ->
      rval =
        id: m.message_id
        subject: m.subject
        created_at: new Date(m.date)
        user:
          screen_name: m.addresses.from.email
          name: m.addresses.from.name
          sent_count: Math.floor(Math.random()*10)
          received_count:  Math.floor(Math.random()*5)

      rval.user.profile_image_url = m.person_info[m.addresses.from.email].thumbnail if m.person_info[m.addresses.from.email]?.thumbnail
      rval
    )
    async.eachLimit messages, 500, getMessage, (err) ->
      done err, messages

module.exports =
  getMessages: getMessages