module "Journey",
  setup: -> console.log "setup"
  teardown: -> console.log "teardown"

test 'its lastMessage is the last object of the messages array', ->
  journey = Sensor.Journey.create()
  message = SC.Object.create()
  journey.addMessage(message)
  SC.run.sync()
  equal journey.get('lastMessage'), message

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
