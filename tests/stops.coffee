vehicle = null
module "Vehicle Stops",
  setup: ->
    vehicle = Sensor.Vehicle.create()
  teardown: ->
    vehicle = null

test "no stops when no messages have been received", ->
  equals vehicle.getPath('stops.length'), 0

test "no stops when the first journey is underway", ->
  messages = messageFactory [
    {usn: Sensor.IGNITION_ON,  time: '01:10'},
    {usn: Sensor.MOVING, time: '01:11'},
    {usn: Sensor.MOVING, time: '01:12'}
  ]
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime '2011-08-27T01:13:00Z', ->
    equals vehicle.getPath('stops.length'), 0

test "one stop when the first journey is finished", ->
  messages = messageFactory [
    {usn: Sensor.IGNITION_ON,  time: '01:10'},
    {usn: Sensor.MOVING, time: '01:11'},
    {usn: Sensor.IGNITION_OFF, time: '01:12', address: 'London'}
  ]
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime '2011-08-27T01:13:00Z', ->
    equals vehicle.getPath('stops.length'), 1
    stop1 = vehicle.getPath('stops.firstObject')
    equals stop1.get('arriveTime').toFormattedString('%H:%M'), '01:12', "arriveTime is correct"
    equals stop1.get('address'), 'London'
    equals stop1.get('leaveTime'), undefined

test "one stop when the first journey is finished without an ignition off", ->
  messages = messageFactory [
    {id: 1, usn: Sensor.IGNITION_ON,  time: '01:10'},
    {id: 2, usn: Sensor.MOVING, time: '01:11'},
    {id: 3, usn: Sensor.MOVING, time: '01:12', address: 'London'}
  ]
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime '2011-08-27T09:00:00Z', ->
    equals vehicle.getPath('stops.length'), 1
    stop1 = vehicle.getPath('stops.firstObject')
    equals stop1.get('arriveTime').toFormattedString('%H:%M'), '01:12'
    equals stop1.get('address'), 'London'
    equals stop1.get('leaveTime'), undefined

test "one stop when the second journey is underway", ->
  messages = messageFactory [
    {id: 1, usn: Sensor.IGNITION_ON,  time: '01:10'},
    {id: 2, usn: Sensor.MOVING,       time: '01:11'},
    {id: 3, usn: Sensor.IGNITION_OFF, time: '01:12', address: 'London'}
    {id: 4, usn: Sensor.IGNITION_ON,  time: '01:22'},
    {id: 5, usn: Sensor.MOVING,       time: '01:23'},
  ]
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime '2011-08-27T01:24:00Z', ->
    equals vehicle.getPath('stops.length'), 1
    stop1 = vehicle.getPath('stops.firstObject')
    equals stop1.get('arriveTime').toFormattedString('%H:%M'), '01:12'
    equals stop1.get('address'), 'London'
    equals stop1.get('leaveTime').toFormattedString('%H:%M'), '01:22'

test "one stop when there is a rogue moving message after first journey", ->
  messages = messageFactory [
    {usn: Sensor.IGNITION_ON,  time: '01:10'},
    {usn: Sensor.MOVING,       time: '01:11'},
    {usn: Sensor.IGNITION_OFF, time: '01:12'},
    {usn: Sensor.MOVING,       time: '01:13'},
  ]
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime '2011-08-27T01:24:00Z', ->
    equals vehicle.getPath('stops.length'), 1, "correct number of stops"
    equals vehicle.getPath('journeys.length'), 1, "correct number of journeys"
    stop1 = vehicle.getPath('stops.firstObject')
    equals stop1.get('arriveTime').toFormattedString('%H:%M'), '01:12'

test "one stop when there are loads of rogue ignition messages after first journey", ->
  messages = messageFactory [
    {usn: Sensor.IGNITION_ON,  time: '07:58'},
    {usn: Sensor.MOVING,       time: '07:59'},
    {usn: Sensor.IGNITION_OFF, time: '08:00'},
    {usn: Sensor.IGNITION_ON,  time: '09:11'},
    {usn: Sensor.IGNITION_ON,  time: '10:04'},
    {usn: Sensor.IGNITION_OFF,  time: '10:05'}
  ]
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime '2011-08-27T10:30:00Z', ->
    equals vehicle.getPath('journeys.length'), 1, "correct number of journeys"
    equals vehicle.getPath('stops.length'), 1, "correct number of stops"
    stop1 = vehicle.getPath('stops.firstObject')
    equals stop1.get('arriveTime').toFormattedString('%H:%M'), '08:00'
