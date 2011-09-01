Sensor.VehiclesController = SC.ArrayProxy.extend
  content: []
  findById: (id) ->
    @get('content').find (v) -> v.get('id') == id

