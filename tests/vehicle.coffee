module "Vehicle",
  setup: ->
    console.log "setup"
  teardown: -> console.log "teardown"

atTime = (time,func) ->
  console.log "changing time to ", time
  date = SC.DateTime.parse(time,'%Y-%m-%dT%H:%M:%SZ')
  this.clock = sinon.useFakeTimers(date.get('milliseconds'),"Date")
  func()
  this.clock.restore()
  console.log "time restored to ", new Date()

test 'can be initialized without any data', ->
  ok Sensor.Vehicle.create()

test 'can be initialized with data', ->
  vehicle =  Sensor.Vehicle.create
    registration: 'P718 MLL'
  equal vehicle.get('registration'), 'P718 MLL'

test 'longitude is set by the last message', ->
  vehicle =  Sensor.Vehicle.create()
  message = {
    lon: 51
  }
  vehicle.updateWithMessages message
  SC.run.sync()
  equal vehicle.get('lon'), 51

test 'latitude is set by the last message', ->
  vehicle =  Sensor.Vehicle.create()
  message = {
    lat: -2
  }
  vehicle.updateWithMessages message
  SC.run.sync()
  equal vehicle.getPath('lat'), -2

test 'heading is set by the last message', ->
  vehicle =  Sensor.Vehicle.create()
  message = {
    heading: 90
  }
  vehicle.updateWithMessages message
  SC.run.sync()
  equal vehicle.getPath('heading'), 90

test 'journeys are not incorrectly cached', ->
  vehicle =  Sensor.Vehicle.create()
  equal vehicle.getPath('journeys.length'), 0, "zero journeys before any messages received"
  messages = [
   {usn: Sensor.IGNITION_ON,  time: '01:10'},
   {usn: Sensor.MOVING,       time: '01:11'},
  ].map (message) -> { usn: message.usn, datetime: "2011-08-27T#{message.time}:11Z"}
  vehicle.updateWithMessages messages
  atTime '2011-08-27T09:00:00Z', ->
    SC.run.sync()
    equal vehicle.getPath('journeys.length'), 1, "it hasn't cached zero journeys"

test 'bindings to a journey are not lost when a new journey is created', ->
  vehicle =  Sensor.Vehicle.create()
  messages = [
   {usn: Sensor.IGNITION_ON,  time: '01:10'},
   {usn: Sensor.MOVING,       time: '01:11'},
   {usn: Sensor.IGNITION_OFF, time: '01:12'}
  ].map (message) -> { usn: message.usn, datetime: "2011-08-27T#{message.time}:11Z"}
  vehicle.updateWithMessages messages
  SC.run.sync()
  Sensor.journey1 = vehicle.getPath('journeys.firstObject')
  boundObject = SC.Object.create fooBinding: 'Sensor.journey1.foo'
  SC.run.sync()
  equal Sensor.journey1.get('foo'), undefined, "journey1#foo should not have changed before the sync"
  boundObject.set('foo', true)
  SC.run.sync()
  equal Sensor.journey1.get('foo'), true, "the binding should have changed journey1#foo"
  # Create a new journey
  messages = [
   {usn: Sensor.IGNITION_ON,  time: '02:10'},
   {usn: Sensor.MOVING,       time: '02:11'},
   {usn: Sensor.IGNITION_OFF, time: '02:12'}
  ].map (message) -> { usn: message.usn, datetime: "2011-08-27T#{message.time}:11Z"}
  vehicle.updateWithMessages messages
  SC.run.sync()
  # Check that the binding is still in place
  journey1 = vehicle.getPath('journeys.firstObject')
  equal journey1.get('foo'), true, "the value hasn't changed"
  boundObject.set('foo', false)
  SC.run.sync()
  equal journey1.get('foo'), false, "the binding still works"
