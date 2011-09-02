Sensor.Journey = SC.Object.extend
  init: ->
    @set('messages', SC.ArrayProxy.create(content: []))
    @set('stop', Sensor.Stop.create(journey: this))
  addMessage: (message) ->
    @get('messages').pushObject(message)
  startMessageBinding: '.messages.firstObject'
  id: ( ->
    @getPath('messages.firstObject.id')
  ).property()
  startAddress: ( -> @getPath('messages.firstObject.address')).property()
  startTime: ( -> @getPath('messages.firstObject.datetime')).property()
  endTime: ( -> @getPath('messages.lastObject.datetime')).property()
  endAddress: ( -> @getPath('messages.lastObject.address')).property()
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
  state: (datetime = SC.DateTime.create())->
    lastMessage = @lastMessage(datetime)
    time = datetime.get('milliseconds')
    return 'unknown' unless lastMessage
    return 'finished' if lastMessage.get('usn') == Sensor.IGNITION_OFF
    return 'finished' if (time > lastMessage.getPath('datetime.milliseconds') && @get('forceFinished') == true)
    if lastMessage.getPath('datetime.milliseconds') > (time - 1000*60*10)
      return 'unfinished'
    "finished"
  moved: ( ->
    usns = @get('messages').map (m) -> m.get('usn')
    _.include usns, Sensor.MOVING
  ).property()
  valid: ->
    @get('moved') or @isRecent()
  isRecent: ->
    lastMessagetime = @getPath('messages.lastObject.datetime.milliseconds')
    lastMessagetime > (SC.DateTime.create().get('milliseconds') - 1000*60*10)
  lastMessage: (datetime = SC.DateTime.create()) ->
    time = datetime.get('milliseconds')
    messages = @getPath('messages.content').slice(0).reverse()
    _.detect messages, (m) ->
      m.getPath('datetime.milliseconds') < time
