Sensor.Vehicle = SC.Object.extend
  init: ->
    @set('_journeys', Sensor.Journeys.create(content: []))
    @set('messages', SC.ArrayProxy.create(content: []))
    @set('_stops', SC.ArrayProxy.create(content: []))
    @_super()
  updateWithMessages: (messages) ->
    messages = [messages] if !$.isArray(messages)
    @get('messages').pushObjects(messages)
    messages.forEach( ((message) ->
      if message.get('usn') == Sensor.IGNITION_ON
        journey = @createJourney(message)
        journey.addMessage(message)
      if message.get('usn') == Sensor.IGNITION_OFF
        journey = @getPath('_journeys.lastObject')
        if journey
          journey.addMessage(message)
          @finishJourney(journey)
      if message.get('usn') == Sensor.MOVING
        if journey = @getPath('_journeys.lastObject')
          if journey.state(message.get('datetime')) == 'unfinished'
            journey.addMessage(message)
        else
          if previousStagedMessage = @stagedMessage(message.get('datetime'))
            journey = @createJourney(previousStagedMessage)
            journey.addMessage(previousStagedMessage)
        @staged = message
    ), this)
  stops: ( ->
    # Need to account for the fact that a journey may not have
    # had an ignition off and hence become 'stopped' due to 
    # timing out.  If this has happened then we will be one stop
    # short and we need to create the last stop
    _stops = @get('_stops')
    if lastJourney = @getPath('_journeys.lastObject')
      if (lastJourney.state() == 'finished') && (lastJourney.getPath('endTime.milliseconds') != @getPath('_stops.lastObject.arriveTime.milliseconds'))
        @createStop(lastJourney.getPath('messages.lastObject'))
    _stops
  ).property()
  journeys: ( ->
    _journeys = @get('_journeys')
    filteredJourneys = _journeys.filter (j) -> j.valid()
    @setPath('_journeys.content', filteredJourneys)
    @get('_journeys')
  ).property()
  lastMessageBinding: '.messages.lastObject'
  latBinding: '.lastMessage.lat'
  lonBinding: '.lastMessage.lon'
  headingBinding: '.lastMessage.heading'
  moved: ( ->
    !!@getPath('_journeys.length')
  ).property('_journeys.length').cacheable()
  createJourney: (message) ->
    if lastJourney = @getPath('_journeys.lastObject')
      lastJourney.finish()
    if lastStop = @getPath('_stops.lastObject')
      lastStop.set('leaveMessage',message)
    journey = Sensor.Journey.create(vehicle: this)
    journey.get('messages').pushObject(message)
    @get('_journeys').pushObject(journey)
    journey
  createStop: (message) ->
    stop = Sensor.Stop.create arriveMessage: message
    @get('_stops').pushObject stop
    stop
  finishJourney: (journey) ->
    journey.finish()
    @createStop(journey.getPath('messages.lastObject'))
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
