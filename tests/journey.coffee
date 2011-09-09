module "Journey",
  setup: -> console.log "setup"
  teardown: -> console.log "teardown"

test "start address is given by the first message", ->
  journey = Sensor.Journey.create()
  journey.addMessage({address: 'London'})
  journey.addMessage({address: 'Manchester'})
  SC.run.sync()
  equal journey.get('startAddress'), 'London'

test "start time is given by the first message", ->
  journey = Sensor.Journey.create()
  time    = SC.DateTime.create(year: 2011)
  journey.addMessage({datetime: time})
  journey.addMessage({datetime: SC.DateTime.create(year: 2012)})
  SC.run.sync()
  equal journey.get('startTime'), time

test "end time is given by the last message", ->
  journey = Sensor.Journey.create()
  time    = SC.DateTime.create(year: 2012)
  journey.addMessage({datetime: SC.DateTime.create(year: 2011)})
  journey.addMessage({datetime: time})
  SC.run.sync()
  equal journey.get('endTime'), time

test "end address is given by the last message", ->
  journey = Sensor.Journey.create()
  journey.addMessage({address: 'London'})
  journey.addMessage({address: 'Manchester'})
  SC.run.sync()
  equal journey.get('endAddress'), 'Manchester'

test "lastMessage", ->
  atTime "2011-08-27T01:09:00Z", ->
    journey = Sensor.Journey.create()
    equals journey.lastMessage(), undefined
    message = Sensor.Message.create
      usn: Sensor.IGNITION_ON
      datetime: SC.DateTime.parse("2011-01-01 01:10","%Y-%m-%d %H:%M")
    journey.addMessage message
    equals journey.lastMessage(), message
    message2 = Sensor.Message.create
      usn: Sensor.IGNITION_ON
      datetime: SC.DateTime.parse("2011-01-01 01:13","%Y-%m-%d %H:%M")
    journey.addMessage message2
    equals journey.lastMessage(), message2
    equals journey.lastMessage(SC.DateTime.parse("2011-01-01 01:12","%Y-%m-%d %H:%M")), message
    equals journey.lastMessage(SC.DateTime.parse("2011-01-01 01:00","%Y-%m-%d %H:%M")), undefined

test "state returns the correct values", ->
  atTime "2011-08-27T01:09:00Z", ->
    journey = Sensor.Journey.create()
    equals journey.state(), 'unknown', 'unknown when no messages'
    message = Sensor.Message.create
      usn: Sensor.IGNITION_ON
      datetime: SC.DateTime.parse("2011-01-01 01:10","%Y-%m-%d %H:%M")
    journey.addMessage message
    equals journey.state(SC.DateTime.parse("2011-01-01 01:11","%Y-%m-%d %H:%M")), 'unfinished'
    equals journey.state(SC.DateTime.parse("2011-01-01 02:00","%Y-%m-%d %H:%M")), 'finished'

test "#distance", ->
    journey = Sensor.Journey.create()
    equals journey.get('distance'), 0
    journey.addMessage Sensor.Message.create(lat:0,lon:0)
    journey.addMessage Sensor.Message.create(lat:1,lon:1)
    journey.addMessage Sensor.Message.create(lat:2,lon:2)
    equals journey.get('distance'), 6716





