Sensor.VehiclesController = SC.ArrayProxy.extend
  content: []
  findById: (id) -> @findProperty('id',id)
  findByImei: (imei) -> @findProperty('imei',imei)
  findByNickname: (nickname) -> @findProperty('nickname',nickname)
  moving: ( ->
    console.log "calculating moving"
    @filterProperty('state','moving')
  ).property('@each.state').cacheable()
  stopped: ( ->
    console.log "calculating stopped"
    @filterProperty('state','stopped')
  ).property('@each.state').cacheable()


