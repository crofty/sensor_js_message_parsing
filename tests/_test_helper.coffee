@atTime = (time,func) ->
  console.log "changing time to ", time
  date = SC.DateTime.parse(time,'%Y-%m-%dT%H:%M:%SZ')
  this.clock = sinon.useFakeTimers(date.get('milliseconds'),"Date")
  func()
  this.clock.restore()
  console.log "time restored to ", new Date()

@messageFactory = (messages) ->
  messages = [messages] if !$.isArray(messages)
  messages.map (message) ->
    Sensor.Message.create
      usn: message.usn
      datetime: SC.DateTime.parse("2011-08-27T#{message.time}",'%Y-%m-%dT%H:%M')
      address: message.address
