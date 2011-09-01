vehicle = null

module "Multiple Journeys",
  setup: ->
    vehicle = Sensor.Vehicle.create()
  teardown: -> console.log "teardown"

test 'Multiple Journeys', ->
  messages = messageFactory [
    {usn: Sensor.IGNITION_ON,  time: '01:10'},
    {usn: Sensor.MOVING,       time: '01:11'},
    {usn: Sensor.IGNITION_OFF, time: '01:12'},
    {usn: Sensor.IGNITION_ON,  time: '01:20'},
    {usn: Sensor.MOVING,       time: '01:21'},
    {usn: Sensor.IGNITION_OFF, time: '01:22'}
  ]
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime "2011-08-27T05:40:00Z", ->
    equal vehicle.getPath('journeys.length'), 2
    journey1 = vehicle.getPath('journeys.firstObject')
    equals journey1.get('startTime').toFormattedString('%H:%M'), '01:10'
    equals journey1.get('endTime').toFormattedString('%H:%M'), '01:12'
    journey2 = vehicle.getPath('journeys.lastObject')
    equals journey2.get('startTime').toFormattedString('%H:%M'), '01:20'
    equals journey2.get('endTime').toFormattedString('%H:%M'), '01:22'
    equals vehicle.get('state'), 'stopped'

test 'Multiple Journeys with stopped time', ->
  messages = messageFactory [
    {usn: Sensor.IGNITION_ON,  time: '01:10'},
    {usn: Sensor.MOVING,       time: '01:11'},
    {usn: Sensor.IGNITION_OFF, time: '01:12'},
    {usn: Sensor.IGNITION_ON,  time: '01:20'},
    {usn: Sensor.MOVING,       time: '01:21'},
    {usn: Sensor.IGNITION_OFF, time: '01:22'}
  ]
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime "2011-08-27T05:40:00Z", ->
    equal vehicle.getPath('journeys.length'), 2
    journey1 = vehicle.getPath('journeys.firstObject')
    equals journey1.get('startTime').toFormattedString('%H:%M'), '01:10'
    equals journey1.get('endTime').toFormattedString('%H:%M'), '01:12'
    equals journey1.get('state'), 'finished'
    equals journey1.get('stoppedFor'), 480000
    journey2 = vehicle.getPath('journeys.lastObject')
    equals journey2.get('startTime').toFormattedString('%H:%M'), '01:20'
    equals journey2.get('endTime').toFormattedString('%H:%M'), '01:22'
    equals journey1.get('state'), 'finished'
    equals vehicle.get('state'), 'stopped'

test 'Multiple Journeys when the first has no ignition off', ->
  messages = messageFactory [
    {usn: Sensor.IGNITION_ON,  time: '01:10'},
    {usn: Sensor.MOVING,       time: '01:11'},
    {usn: Sensor.MOVING,       time: '01:12'},
    {usn: Sensor.MOVING,       time: '01:13'},
    {usn: Sensor.IGNITION_ON,  time: '01:15'},
    {usn: Sensor.MOVING,       time: '01:16'},
    {usn: Sensor.IGNITION_OFF, time: '01:17'}
  ]
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime "2011-08-27T01:18:00Z", ->
    equal vehicle.getPath('journeys.length'), 2
    journey1 = vehicle.getPath('journeys.firstObject')
    equals journey1.get('startTime').toFormattedString('%H:%M'), '01:10'
    equals journey1.get('endTime').toFormattedString('%H:%M'), '01:13'
    equals journey1.get('state'), 'finished'
    equals journey1.get('stoppedFor'), 120000
    journey2 = vehicle.getPath('journeys.lastObject')
    equals journey2.get('startTime').toFormattedString('%H:%M'), '01:15'
    equals journey2.get('endTime').toFormattedString('%H:%M'), '01:17'
    equals journey1.get('state'), 'finished'
    equals vehicle.get('state'), 'stopped'

test 'Journeys on different days', ->
  messages = [{usn: Sensor.IGNITION_ON,  time: '2011-08-27T01:10'},
   {usn: Sensor.MOVING,       time: '2011-08-27T01:11'},
   {usn: Sensor.IGNITION_OFF, time: '2011-08-27T01:12'},
   {usn: Sensor.IGNITION_ON,  time: '2011-09-27T01:01'},
   {usn: Sensor.MOVING,       time: '2011-09-27T01:02'},
   {usn: Sensor.IGNITION_OFF, time: '2011-09-27T01:03'}
  ].map (message) ->
    Sensor.Message.create
      usn: message.usn
      datetime: SC.DateTime.parse(message.time,'%Y-%m-%dT%H:%M')
  vehicle.updateWithMessages(messages)
  SC.run.sync()
  atTime "2011-08-27T01:18:00Z", ->
    equal vehicle.getPath('journeys.length'), 2
    journey1 = vehicle.getPath('journeys.firstObject')
    equals journey1.get('startTime').toFormattedString('%H:%M'), '01:10'
    equals journey1.get('endTime').toFormattedString('%H:%M'), '01:12'
    equals journey1.get('state'), 'finished'
    equals journey1.get('stoppedFor'), 2677740000 #TODO: check that this is correct, maybe it should be 85740000
    journey2 = vehicle.getPath('journeys.lastObject')
    equals journey2.get('startTime').toFormattedString('%H:%M'), '01:01'
    equals journey2.get('endTime').toFormattedString('%H:%M'), '01:03'
    equals journey1.get('state'), 'finished'
    equals vehicle.get('state'), 'stopped'
