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
    console.log "calculating stops"
    journeys = @getPath('journeys.content').slice(0)
    if journeys
      journeys.filter((j) -> j.state() == 'finished').map (j) -> j.get('stop')
  ).property('_journeys.length').cacheable()
  journeys: ( ->
    console.log "calculating journeys"
    _journeys = @get('_journeys')
    if _journeys
      filteredJourneys = _journeys.filter (j) -> j.valid()
      @setPath('_journeys.content', filteredJourneys)
      @get('_journeys')
  ).property('_journeys.length').cacheable()
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
  finishJourney: (journey) ->
    journey.finish()
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
