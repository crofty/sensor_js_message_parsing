Sensor.Message = SC.Object.extend
  init: ->
    datetime = @get('datetime')
    if typeof(datetime) == "string"
      datetimeInCurrentTimezone = SC.DateTime.parse(datetime,'%Y-%m-%dT%H:%M:%S%Z').adjust(timezone: (new Date()).getTimezoneOffset())
      @set('datetime', datetimeInCurrentTimezone)
