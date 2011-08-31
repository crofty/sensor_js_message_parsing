Sensor.Vehicle = SC.Object.extend
  init: ->
    @set('journeys', Sensor.Journeys.create(content: []))
    @set('messages', SC.ArrayProxy.create(content: []))
  updateWithMessages: (dataArray) ->
    dataArray = [dataArray] if !$.isArray(dataArray)
    dataArray.forEach (data) =>
      message       = Sensor.Message.create(data)
      @get('messages').pushObject(message)
      if message.get('usn') == Sensor.IGNITION_ON
        journey = @createJourney(message)
      if message.get('usn') == Sensor.IGNITION_OFF
        journey = @getPath('journeys.lastObject')
        if journey
          journey.finish()
          if journey.getPath('lastMessage.usn') == Sensor.IGNITION_ON
            @get('journeys').removeObject(journey)
            journey.destroy()
      if message.get('usn') == Sensor.MOVING
        if journey = @getPath('journeys.lastObject')
        else
          if previousStagedMessage = @stagedMessage(message.get('datetime'))
            journey = @createJourney(previousStagedMessage)
            journey.addMessage(previousStagedMessage)
        @staged = message
      journey.addMessage(message) if journey
  lastMessageBinding: '.messages.lastObject'
  latBinding: '.lastMessage.lat'
  lonBinding: '.lastMessage.lon'
  headingBinding: '.lastMessage.heading'
  movedBinding: SC.Binding.oneWay().bool().from('journeys')
  createJourney: (message) ->
    if lastJourney = @getPath('journeys.lastObject')
      lastJourney.finish()
    journey = Sensor.Journey.create(vehicle: this)
    @get('journeys').pushObject(journey)
    journey
  state: ( ->
    lastMessage = @getPath('messages.lastObject')
    return 'stopped' unless lastMessage
    return 'stopped' if lastMessage.get('usn') == Sensor.IGNITION_OFF
    if lastMessage.getPath('datetime.milliseconds') > (new Date - 1000*60*5)
      'moving'
    else
      'stopped'
  ).property()
  stagedMessage: (datetime=SC.DateTime.create())->
    return @staged if @staged && @staged.getPath('datetime.milliseconds') > (datetime.get('milliseconds')- 1000*60*5)
  stops: ( ->
    journeys = @getPath('journeys.content')
    stops = []
    _.each journeys, (journey,i) ->
      nextJourney = journeys[i+1]
      if journey.get('state') == 'finished'
        stops.push Sensor.Stop.create
          arriveMessage: journey.getPath('messages.lastObject')
          leaveMessage: nextJourney?.getPath('messages.firstObject')
    SC.ArrayProxy.create(content: stops)
  ).property('journeys').cacheable()
