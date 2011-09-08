Sensor.Stop = SC.Object.extend
  init: ->
    @_super()
  id: ( ->
    'stop-' + @getPath('journey.id')
  ).property()
  # arriveTime: ( ->
  #   @getPath('arriveMessage.datetime')
  # ).property('arriveMessage').cacheable()
  # address: ( ->
  #   @getPath('arriveMessage.address')
  # ).property('arriveMessage').cacheable()
  # leaveTime: ( ->
  #   @getPath('leaveMessage.datetime')
  # ).property('leaveMessage').cacheable()
  # duration: ( ->
  #   @getPath('leaveMessage.datetime.milliseconds') - @getPath('arriveMessage.datetime.milliseconds')
  # ).property()
  arriveTime: ( -> @getPath('journey.messages.lastObject.datetime') ).property()
  address:    ( -> @getPath('journey.messages.lastObject.address') ).property()
  addressMessage: ( -> @getPath('journey.messages.lastObject') ).property()
  lat:    ( -> @getPath('journey.messages.lastObject.lat') ).property()
  lon:    ( -> @getPath('journey.messages.lastObject.lon') ).property()
  nextJourney: ->
    journey = @get('journey')
    journeys = @getPath('journey.vehicle.journeys').slice(0)
    journeys.find (j) -> j.get('id') > journey.get('id')
  leaveTime: ( ->
    if nextJourney = @nextJourney()
      nextJourney.get('startTime')
  ).property()
  duration: ( ->
    if nextJourney = @nextJourney()
      nextJourney.getPath('startTime.milliseconds') - @getPath('journey.endTime.milliseconds')
  ).property()
