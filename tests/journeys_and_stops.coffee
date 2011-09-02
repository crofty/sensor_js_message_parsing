vehicle = null

module "Journeys and Stops",
  setup: ->
    vehicle = Sensor.Vehicle.create()
  teardown: -> console.log "teardown"

