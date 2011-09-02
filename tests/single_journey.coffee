vehicle = null

module "Single Journey",
  setup: ->
    vehicle = Sensor.Vehicle.create()

test 'Ignition On', ->
  message = Sensor.Message.create
    usn: Sensor.IGNITION_ON
    datetime: SC.DateTime.parse('2011-08-27T05:37:11Z','%Y-%m-%dT%H:%M')
    address: 'London'
  vehicle.updateWithMessages message
  atTime "2011-08-27T05:40:00Z", ->
    SC.run.sync()
    journey1 = vehicle.getPath('journeys.firstObject')
    equals journey1.get('startTime').toFormattedString('%H:%M'), '05:37'
    equals journey1.get('startAddress'), 'London'
    equals journey1.get('endTime').toFormattedString('%H:%M'), '05:37'
    equals journey1.get('endAddress'), 'London'
    equals journey1.state(), 'unfinished'
    equals vehicle.get('state'), 'moving'

test 'Ignition Off', ->
  messages = messageFactory [
    usn: Sensor.IGNITION_OFF
    datetime: SC.DateTime.parse('2011-08-27T01:10:11Z','%Y-%m-%dT%H:%M')
    address: 'London'
  ]
  vehicle.updateWithMessages messages
  atTime "2011-08-27T02:11:00Z", ->
    SC.run.sync()
    equals vehicle.getPath('journeys.length'), 0
    equals vehicle.get('state'), 'stopped'

test 'Recent unfinished journey', ->
  atTime "2011-08-27T01:09:00Z", ->
    messages = messageFactory [
     {usn: Sensor.IGNITION_ON,  time: '01:10', address: 'London'},
     {usn: Sensor.MOVING,       time: '01:11', address: 'Manchester'}
    ]
    vehicle.updateWithMessages(messages)
    SC.run.sync()

    atTime "2011-08-27T01:12:00Z", ->
      journey1 = vehicle.getPath('journeys.firstObject')
      equals journey1.get('startTime').toFormattedString('%H:%M'), '01:10'
      equals journey1.get('startAddress'), 'London'
      equals journey1.get('endTime').toFormattedString('%H:%M'), '01:11'
      equals journey1.get('endAddress'), 'Manchester'
      equals journey1.state(), 'unfinished'
      equals vehicle.get('state'), 'moving'

test 'Finished journey', ->
  messages = messageFactory [
    {usn: Sensor.IGNITION_ON,  time: '01:10', address: 'London'},
    {usn: Sensor.MOVING,       time: '01:11', address: 'Birmingham'},
    {usn: Sensor.IGNITION_OFF, time: '01:12', address: 'Manchester'}
  ]
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime '2011-08-27T01:13:00Z', ->
    equals vehicle.getPath('journeys.length'), 1
    journey1 = vehicle.getPath('journeys.firstObject')
    equals journey1.get('startTime').toFormattedString('%H:%M'), '01:10'
    equals journey1.get('startAddress'), 'London'
    equals journey1.get('endTime').toFormattedString('%H:%M'), '01:12'
    equals journey1.get('endAddress'), 'Manchester'
    equals journey1.state(), 'finished'
    equals vehicle.get('state'), 'stopped'

test 'Long ago finished journey with no ignition off', ->
  messages = messageFactory [
    {usn: Sensor.IGNITION_ON,  time: '01:10'},
    {usn: Sensor.MOVING,       time: '01:11'}
  ]
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime "2011-08-27T09:00:00Z", ->
    journey1 = vehicle.getPath('journeys.firstObject')
    equals journey1.get('startTime').toFormattedString('%H:%M'), '01:10'
    equals journey1.get('endTime').toFormattedString('%H:%M'), '01:11'
    equals journey1.state(), 'finished'
    equals vehicle.get('state'), 'stopped'

test 'Journey with no ignition on', ->
  messages = messageFactory [
    {usn: Sensor.MOVING,  time: '01:10'},
    {usn: Sensor.MOVING,       time: '01:11'},
    {usn: Sensor.MOVING,       time: '01:12'},
    {usn: Sensor.IGNITION_OFF, time: '01:13'}
  ]
  vehicle.updateWithMessages(messages)
  atTime "2011-08-27T09:00:00Z", ->
    SC.run.sync()
    journey1 = vehicle.getPath('journeys.firstObject')
    equals journey1.get('startTime').toFormattedString('%H:%M'), '01:10'
    equals journey1.get('endTime').toFormattedString('%H:%M'), '01:13'
    equals journey1.state(), 'finished'
    equals vehicle.get('state'), 'stopped'

test 'Journey with no ignition on or off', ->
  atTime "2011-08-27T01:09:00Z", ->
    messages = messageFactory [
      {usn: Sensor.MOVING,  time: '01:10'},
      {usn: Sensor.MOVING,       time: '01:11'},
      {usn: Sensor.MOVING,       time: '01:12'}
    ]
    vehicle.updateWithMessages(messages)
    SC.run.sync()
    atTime '2011-08-27T09:00:00Z', ->
      journey1 = vehicle.getPath('journeys.firstObject')
      equals journey1.get('startTime').toFormattedString('%H:%M'), '01:10'
      equals journey1.get('endTime').toFormattedString('%H:%M'), '01:12'
      equals journey1.state(), 'finished'
      equals vehicle.get('state'), 'stopped'

# test 'An ignition on and off with no movement', ->
#   messages = [{usn: Sensor.IGNITION_ON,  time: '01:10'},
#    {usn: Sensor.IGNITION_OFF,       time: '01:11'}
#   ].map (message) -> {usn: message.usn, datetime: "2011-08-27T#{message.time}:11Z"}
#   vehicle.updateWithMessages(messages)
#   atTime '2011-08-27T09:00:00Z', ->
#     SC.run.sync()
#     equal vehicle.getPath('journeys.length'), 0

test 'Random moving GPS blips', ->
  messages = messageFactory
    usn: Sensor.MOVING
    datetime: '01:10'
  vehicle.updateWithMessages messages
  atTime '2011-08-27T09:00:00Z', ->
    SC.run.sync()
    equal vehicle.getPath('journeys.length'), 0

test 'Random ignition on GPS blips', ->
  message = Sensor.Message.create
    usn: Sensor.IGNITION_ON
    datetime: SC.DateTime.parse('2011-08-27T01:10:00Z','%Y-%m-%dT%H:%M')
    address: 'London'
  vehicle.updateWithMessages message
  console.log "update finished"
  atTime '2011-08-27T09:00:00Z', ->
    console.log "sync started"
    SC.run.sync()
    console.log "sync finsihed"
    equal vehicle.getPath('journeys.length'), 0
