Sensor.Journey = SC.Object.extend
  init: ->
    @set('messages', SC.ArrayProxy.create(content: []))
  addMessage: (message) ->
    @get('messages').pushObject(message)
  lastMessageBinding: '.messages.lastObject'
  startMessageBinding: '.messages.firstObject'
  startAddress: ( -> @getPath('startMessage.address')).property('startMessage').cacheable()
  startTime: ( -> @getPath('startMessage.datetime')).property('startMessage').cacheable()
  endTime: ( -> @getPath('lastMessage.datetime')).property('lastMessage').cacheable()
  endAddress: ( -> @getPath('lastMessage.address')).property('lastMessage').cacheable()
  stoppedFor: ( ->
    rawJourneys = @getPath('vehicle.journeys.content')
    if nextJourney = _.detect rawJourneys, ((j) => j.get('startTime') > @get('startTime'))
      nextStartTime = nextJourney.getPath('startTime.milliseconds')
      stoppedFor = nextStartTime - @getPath('endTime.milliseconds')
  ).property()
  # duration: ( ->
  #   @getPath('lastMessage.datetime') - @get('startTime')
  # ).property()
  finish: ->
    @set('forceFinished',true)
  state: ( ->
    lastMessage = @getPath('messages.lastObject')
    time = SC.DateTime.create().get('milliseconds')
    return 'unknown' unless lastMessage
    return 'finished' if lastMessage.get('usn') == Sensor.IGNITION_OFF
    return 'finished' if (time > lastMessage.getPath('datetime.milliseconds') && @get('forceFinished') == true)
    if lastMessage.getPath('datetime.milliseconds') > (time - 1000*60*10)
      return 'unfinished'
    "finished"
  ).property()
  moved: ( ->
    usns = @get('messages').map (m) -> m.get('usn')
    _.include usns, Sensor.MOVING
  ).property()
