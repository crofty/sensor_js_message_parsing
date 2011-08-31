vehicle = null
module "Vehicle Stops",
  setup: ->
    vehicle = Sensor.Vehicle.create()
  teardown: ->
    vehicle = null

atTime = (time,func) ->
  console.log "changing time to ", time
  date = SC.DateTime.parse(time,'%Y-%m-%dT%H:%M:%SZ')
  this.clock = sinon.useFakeTimers(date.get('milliseconds'),"Date")
  func()
  this.clock.restore()
  console.log "time restored to ", new Date()

test "no stops when no messages have been received", ->
  equals vehicle.getPath('stops.length'), 0

test "no stops when the first journey is underway", ->
  messages = [{usn: Sensor.IGNITION_ON,  time: '01:10'},
   {usn: Sensor.MOVING, time: '01:11'},
   {usn: Sensor.MOVING, time: '01:12'}
  ].map (message) -> {usn: message.usn, datetime: "2011-08-27T#{message.time}:00Z"}
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime '2011-08-27T01:13:00Z', ->
    equals vehicle.getPath('stops.length'), 0

test "one stop when the first journey is finished", ->
  messages = [{usn: Sensor.IGNITION_ON,  time: '01:10'},
   {usn: Sensor.MOVING, time: '01:11'},
   {usn: Sensor.IGNITION_OFF, time: '01:12', address: 'London'}
  ].map (message) -> {usn: message.usn, datetime: "2011-08-27T#{message.time}:11Z", address: message.address}
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime '2011-08-27T01:13:00Z', ->
    equals vehicle.getPath('stops.length'), 1
    stop1 = vehicle.getPath('stops.firstObject')
    equals stop1.get('arriveTime').toFormattedString('%H:%M'), '01:12'
    equals stop1.get('address'), 'London'
    equals stop1.get('leaveTime'), undefined

test "one stop when the first journey is finished without an ignition off", ->
  messages = [{usn: Sensor.IGNITION_ON,  time: '01:10'},
   {usn: Sensor.MOVING, time: '01:11'},
   {usn: Sensor.MOVING, time: '01:12', address: 'London'}
  ].map (message) -> {usn: message.usn, datetime: "2011-08-27T#{message.time}:11Z", address: message.address}
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime '2011-08-27T09:00:00Z', ->
    equals vehicle.getPath('stops.length'), 1
    stop1 = vehicle.getPath('stops.firstObject')
    equals stop1.get('arriveTime').toFormattedString('%H:%M'), '01:12'
    equals stop1.get('address'), 'London'
    equals stop1.get('leaveTime'), undefined

test "one stop when the second journey is underway", ->
  messages = [{usn: Sensor.IGNITION_ON,  time: '01:10'},
   {usn: Sensor.MOVING,       time: '01:11'},
   {usn: Sensor.IGNITION_OFF, time: '01:12', address: 'London'}
   {usn: Sensor.IGNITION_ON,  time: '01:22'},
   {usn: Sensor.MOVING,       time: '01:23'},
  ].map (message) -> {usn: message.usn, datetime: "2011-08-27T#{message.time}:11Z", address: message.address}
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime '2011-08-27T01:24:00Z', ->
    equals vehicle.getPath('stops.length'), 1
    stop1 = vehicle.getPath('stops.firstObject')
    equals stop1.get('arriveTime').toFormattedString('%H:%M'), '01:12'
    equals stop1.get('address'), 'London'
    equals stop1.get('leaveTime').toFormattedString('%H:%M'), '01:22'

