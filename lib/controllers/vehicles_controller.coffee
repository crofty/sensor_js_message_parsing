Sensor.VehiclesController = SC.ArrayProxy.extend
  content: []
  loaded: false
  vehiclesUrl: ( -> "#{Sensor.API_URL}/units?callback=?&oauth_token=#{Sensor.ACCESS_TOKEN}").property()
  messagesUrl: ( -> "#{Sensor.API_URL}/messages?callback=?&oauth_token=#{Sensor.ACCESS_TOKEN}").property()
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
  selected: ( -> @filterProperty('selected') ).property('@each.selected').cacheable()
  load: ->
    console.time "Downloading vehicles"
    $.getJSON @get('vehiclesUrl'), (data) =>
      console.log data
      console.timeEnd "Downloading vehicles"
      console.log "#{data.units.length} vehicles downloaded"
      @loadVehicles(data.units)
      @set('loadedVehicles',true)
      @getMessages()
  loadVehicles: (vehicles) ->
    vehicles.forEach (vehicleData) =>
      vehicle = Sensor.Vehicle.create(vehicleData)
      @pushObject vehicle
  getMessages: ->
    console.time "downloading messages"
    $.getJSON @get('messagesUrl'), (data) =>
      console.timeEnd "downloading messages"
      messages = data.messages
      console.log "#{messages.length} messages downloaded"
      @processMessages(messages)
  processMessages: (messages) ->
    console.time "processing messages"
    @get('content').forEach (vehicle) ->
      # TODO: this can probably be optimised by removing the messages from the data array
      # so that after the messages have been added to a vehicle, we don't need to cycle
      # through those messages again on the next iteration
      vehicleId = vehicle.get('id')
      messagesForVehicle = messages.filter (m) -> m.unit_id == vehicleId
      messageObjects = messagesForVehicle.map (m) ->
        Sensor.Message.create(m)
      vehicle.updateWithMessages(messageObjects)
    console.timeEnd "processing messages"
    @set('loadedMessages', true)
    @subscribeToWebsockets()
  subscribeToWebsockets: ->
    juggernaut = new Juggernaut
      host: Sensor.WEBSOCKET_IP
      port: Sensor.WEBSOCKET_PORT
    juggernaut.on "connect", -> console.log("Connected", juggernaut.socket.getTransport().type)
    juggernaut.on "disconnect", -> console.log("Disconnected")
    juggernaut.on "reconnect",  -> console.log("Reconnecting")
    juggernaut.subscribe Sensor.WEBSOCKET_CHANNEL, (data) =>
      console.log "Websocket data received", data
      message = Sensor.Message.create data
      if vehicle = Sensor.vehiclesController.findById message.get('vehicleId')
        vehicle.updateWithMessages message
