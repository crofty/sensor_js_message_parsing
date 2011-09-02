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
    _.detect journeys.reverse(), (j) ->
      j.getPath('startTime.milliseconds') > journey.getPath('endTime.milliseconds')
  duration: 1000
