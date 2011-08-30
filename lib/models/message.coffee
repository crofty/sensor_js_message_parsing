Sensor.Message = SC.Object.extend
  init: ->
    @set('datetime', SC.DateTime.parse(@get('datetime'),'%Y-%m-%dT%H:%M:%SZ'))
