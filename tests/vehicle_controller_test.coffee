collection = null
module "Vehicles Controller",
  setup: ->
    collection = Sensor.VehiclesController.create()

test ".findById returns the vehicle", ->
  vehicle = Sensor.Vehicle.create id: 1
  collection.pushObject vehicle
  equals collection.findById(1), vehicle

test ".findByImei returns the vehicle", ->
  vehicle = Sensor.Vehicle.create imei: '0120'
  collection.pushObject vehicle
  equals collection.findByImei('0120'), vehicle

