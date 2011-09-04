Sensor.Stop = SC.Object.extend
  init: ->
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
  nextJourney: ->
    journey = @get('journey')
    journeys = @getPath('journey.vehicle.journeys').slice(0)
    console.log "journeys", journeys
    _.detect journeys.reverse(), (j) ->
      j.get('id') > journey.get('id')
  leaveTime: ( ->
    if nextJourney = @nextJourney()
      nextJourney.get('startTime')
  ).property()
  duration: ( ->
    if nextJourney = @nextJourney()
      nextJourney.getPath('startTime.milliseconds') - @getPath('journey.endTime.milliseconds')
  ).property()
