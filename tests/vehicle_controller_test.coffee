collection = null
module "Vehicles Controller",
  setup: ->
    collection = Sensor.VehiclesController.create()

test "#findById returns the vehicle", ->
  vehicle = Sensor.Vehicle.create id: 1
  collection.pushObject vehicle
  equals collection.findById(1), vehicle

test "#findByImei returns the vehicle", ->
  vehicle = Sensor.Vehicle.create imei: '0120'
  collection.pushObject vehicle
  equals collection.findByImei('0120'), vehicle

# test "#moving returns all the moving vehicles", ->
#   movingVehicle = Sensor.Vehicle.create()
#   stoppedVehicle = Sensor.Vehicle.create()
#   collection.pushObjects [movingVehicle, stoppedVehicle]
#   #movingVehicle.set('state','moving')
#   equals collection.get('moving'), [movingVehicle]

test "adding to one vehicle controller does not affect another", ->
  collection2 = Sensor.VehiclesController.create()
  equals collection.get('length'), 0
  equals collection2.get('length'), 0
  collection2.pushObject {}
  equals collection.get('length'), 0
  equals collection2.get('length'), 1
