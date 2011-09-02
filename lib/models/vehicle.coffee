Sensor.Vehicle = SC.Object.extend
  init: ->
    @set('journeys', Sensor.Journeys.create(content: []))
    @set('messages', SC.ArrayProxy.create(content: []))
    @set('_stops', SC.ArrayProxy.create(content: []))
    @_super()
  updateWithMessages: (messages) ->
    messages = [messages] if !$.isArray(messages)
    @get('messages').pushObjects(messages)
    messages.forEach( ((message) ->
      if message.get('usn') == Sensor.IGNITION_ON
        journey = @createJourney(message)
      if message.get('usn') == Sensor.IGNITION_OFF
        journey = @getPath('journeys.lastObject')
        @finishJourney(journey,message) if journey
      if message.get('usn') == Sensor.MOVING
        journey = @getPath('journeys.lastObject')
        if !journey && (previousStagedMessage = @stagedMessage(message.get('datetime')))
          journey = @createJourney(previousStagedMessage)
          journey.addMessage(previousStagedMessage)
        @staged = message
      journey.addMessage(message) if journey
    ), this)
  stops: ( ->
    # Need to account for the fact that a journey may not have
    # had an ignition off and hence become 'stopped' due to 
    # timing out.  If this has happened then we will be one stop
    # short and we need to create the last stop
    _stops = @get('_stops')
    if lastJourney = @getPath('journeys.lastObject')
      if (lastJourney.get('state') == 'finished') && (lastJourney.getPath('endTime.milliseconds') != @getPath('_stops.lastObject.arriveTime.milliseconds'))
        @createStop(lastJourney.getPath('messages.lastObject'))
    _stops
  ).property()
  lastMessageBinding: '.messages.lastObject'
  latBinding: '.lastMessage.lat'
  lonBinding: '.lastMessage.lon'
  headingBinding: '.lastMessage.heading'
  moved: ( ->
    !!@getPath('journeys.length')
  ).property('journeys.length').cacheable()
  createJourney: (message) ->
    if lastJourney = @getPath('journeys.lastObject')
      lastJourney.finish()
    if lastStop = @getPath('_stops.lastObject')
      lastStop.set('leaveMessage',message)
    journey = Sensor.Journey.create(vehicle: this)
    @get('journeys').pushObject(journey)
    journey
  createStop: (message) ->
    stop = Sensor.Stop.create arriveMessage: message
    @get('_stops').pushObject stop
    stop
  finishJourney: (journey,message) ->
    journey.finish()
    @createStop(message)
  state: SC.computed( ->
    console.log "calculating state"
    lastMessage = @getPath('messages.lastObject')
    return 'stopped' unless lastMessage
    return 'stopped' if lastMessage.get('usn') == Sensor.IGNITION_OFF
    if lastMessage.getPath('datetime.milliseconds') > (new Date - 1000*60*5)
      'moving'
    else
      'stopped'
  ).property('messages.lastObject').cacheable() #'messages.lastObject').cacheable()
  stagedMessage: (datetime=SC.DateTime.create())->
    return @staged if @staged && @staged.getPath('datetime.milliseconds') > (datetime.get('milliseconds')- 1000*60*5)
