vehicle = null

module "Single Journey",
  setup: ->
    vehicle = Sensor.Vehicle.create()

atTime = (time,func) ->
  console.log "changing time to ", time
  date = SC.DateTime.parse(time,'%Y-%m-%dT%H:%M:%SZ')
  this.clock = sinon.useFakeTimers(date.get('milliseconds'),"Date")
  func()
  this.clock.restore()
  console.log "time restored to ", new Date()

test 'Ignition On', ->
  message =
    usn: Sensor.IGNITION_ON
    datetime: '2011-08-27T05:37:11Z'
    address: 'London'
  vehicle.updateWithMessages message
  atTime "2011-08-27T05:40:00Z", ->
    SC.run.sync()
    journey1 = vehicle.getPath('journeys.firstObject')
    equals journey1.get('startTime').toFormattedString('%H:%M'), '05:37'
    equals journey1.get('startAddress'), 'London'
    equals journey1.get('endTime').toFormattedString('%H:%M'), '05:37'
    equals journey1.get('endAddress'), 'London'
    equals journey1.get('state'), 'unfinished'
    equals vehicle.get('state'), 'moving'

test 'Ignition Off', ->
  message =
    usn: Sensor.IGNITION_OFF
    datetime: '2011-08-27T01:10:11Z'
    address: 'London'
  vehicle.updateWithMessages message
  SC.run.sync()
  equals vehicle.getPath('journeys.length'), 0
  equals vehicle.get('state'), 'stopped'

test 'Recent unfinished journey', ->
  messages = [{usn: Sensor.IGNITION_ON,  time: '01:10', address: 'London'},
   {usn: Sensor.MOVING,       time: '01:11', address: 'Manchester'}
  ].map (message) -> { usn: message.usn, datetime: "2011-08-27T#{message.time}:11Z", address: message.address}
  vehicle.updateWithMessages(messages)
  SC.run.sync()

  atTime "2011-08-27T01:12:00Z", ->
    journey1 = vehicle.getPath('journeys.firstObject')
    equals journey1.get('startTime').toFormattedString('%H:%M'), '01:10'
    equals journey1.get('startAddress'), 'London'
    equals journey1.get('endTime').toFormattedString('%H:%M'), '01:11'
    equals journey1.get('endAddress'), 'Manchester'
    equals journey1.get('state'), 'unfinished'
    equals vehicle.get('state'), 'moving'

test 'Finished journey', ->
  messages = [{usn: Sensor.IGNITION_ON,  time: '01:10', address: 'London'},
   {usn: Sensor.MOVING,       time: '01:11', address: 'Birmingham'},
   {usn: Sensor.IGNITION_OFF, time: '01:12', address: 'Manchester'}
  ].map (message) -> { usn: message.usn, datetime: "2011-08-27T#{message.time}:11Z", address: message.address}
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime '2011-08-27T01:13:00Z', ->
    equals vehicle.getPath('journeys.length'), 1
    journey1 = vehicle.getPath('journeys.firstObject')
    equals journey1.get('startTime').toFormattedString('%H:%M'), '01:10'
    equals journey1.get('startAddress'), 'London'
    equals journey1.get('endTime').toFormattedString('%H:%M'), '01:12'
    equals journey1.get('endAddress'), 'Manchester'
    equals journey1.get('state'), 'finished'
    equals vehicle.get('state'), 'stopped'

test 'Long ago finished journey with no ignition off', ->
  messages = [{usn: Sensor.IGNITION_ON,  time: '2011-08-27T01:10:00Z'},
   {usn: Sensor.MOVING,       time: '2011-08-27T01:11:00Z'}
  ].map (message) -> { usn: message.usn, datetime: message.time}
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime "2011-08-27T09:00:00Z", ->
    journey1 = vehicle.getPath('journeys.firstObject')
    equals journey1.get('startTime').toFormattedString('%H:%M'), '01:10'
    equals journey1.get('endTime').toFormattedString('%H:%M'), '01:11'
    equals journey1.get('state'), 'finished'
    equals vehicle.get('state'), 'stopped'

test 'Journey with no ignition on', ->
  messages = [{usn: Sensor.MOVING,  time: '01:10'},
   {usn: Sensor.MOVING,       time: '01:11'},
   {usn: Sensor.MOVING,       time: '01:12'},
   {usn: Sensor.IGNITION_OFF, time: '01:13'}
  ].map (message) -> {usn: message.usn, datetime: "2011-08-27T#{message.time}:11Z"}
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  journey1 = vehicle.getPath('journeys.firstObject')
  equals journey1.get('startTime').toFormattedString('%H:%M'), '01:10'
  equals journey1.get('endTime').toFormattedString('%H:%M'), '01:13'
  equals journey1.get('state'), 'finished'
  equals vehicle.get('state'), 'stopped'

test 'Journey with no ignition on or off', ->
  messages = [{usn: Sensor.MOVING,  time: '01:10'},
   {usn: Sensor.MOVING,       time: '01:11'},
   {usn: Sensor.MOVING,       time: '01:12'}
  ].map (message) -> {usn: message.usn, datetime: "2011-08-27T#{message.time}:11Z"}
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime '2011-08-27T09:00:00Z', ->
    journey1 = vehicle.getPath('journeys.firstObject')
    equals journey1.get('startTime').toFormattedString('%H:%M'), '01:10'
    equals journey1.get('endTime').toFormattedString('%H:%M'), '01:12'
    equals journey1.get('state'), 'finished'
    equals vehicle.get('state'), 'stopped'

test 'An ignition on and off with no movement', ->
  messages = [{usn: Sensor.IGNITION_ON,  time: '01:10'},
   {usn: Sensor.IGNITION_OFF,       time: '01:11'}
  ].map (message) -> {usn: message.usn, datetime: "2011-08-27T#{message.time}:11Z"}
  vehicle.updateWithMessages(messages)
  atTime '2011-08-27T09:00:00Z', ->
    SC.run.sync()
    equal vehicle.getPath('journeys.length'), 0

test 'Random moving GPS blips', ->
  vehicle.updateWithMessages(
    usn: Sensor.MOVING
    datetime: '2011-08-27T01:10:00Z'
    address: 'London'
  )
  atTime '2011-08-27T09:00:00Z', ->
    SC.run.sync()
    equal vehicle.getPath('journeys.length'), 0

test 'Random ignition on GPS blips', ->
  vehicle.updateWithMessages(
    usn: Sensor.IGNITION_ON
    datetime: '2011-08-27T01:10:00Z'
    address: 'London'
  )
  atTime '2011-08-27T09:00:00Z', ->
    SC.run.sync()
    equal vehicle.getPath('journeys.length'), 0
