Sensor.Stop = SC.Object.extend
  init: ->
  arriveTime: ( ->
    @getPath('arriveMessage.datetime')
  ).property('arriveMessage').cacheable()
  address: ( ->
    @getPath('arriveMessage.address')
  ).property('arriveMessage').cacheable()
  leaveTime: ( ->
    @getPath('leaveMessage.datetime')
  ).property('leaveMessage').cacheable()
  duration: ( ->
    @getPath('leaveMessage.datetime.milliseconds') - @getPath('arriveMessage.datetime.milliseconds')
  ).property()
