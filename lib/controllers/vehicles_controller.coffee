Sensor.VehiclesController = SC.ArrayProxy.extend
  content: []
  findById: (id) ->
    @get('content').find (v) -> v.get('id') == id
  findByImei: (imei) ->
    @get('content').find (v) -> v.get('imei') == imei

