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
    if typeof(message.time) == 'string'
      message.time = SC.DateTime.parse("2011-08-27T#{message.time}",'%Y-%m-%dT%H:%M')
    Sensor.Message.create
      id: message.id
      usn: message.usn
      datetime: message.time
      address: message.address
