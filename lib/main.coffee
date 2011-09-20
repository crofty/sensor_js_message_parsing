require('sproutcore')
require('sproutcore-datetime')
Sensor ?= SC.Application.create()
require('sensor-geo')
Sensor.IGNITION_ON = 64
Sensor.IGNITION_OFF = 65
Sensor.MOVING = 333

# Address Types
Sensor.Address = {}
Sensor.Address.NOMINATIM = -1
Sensor.Address.POI = 0
Sensor.Address.GOOGLE = 1

require('sensor-js-message-parsing/controllers/journeys')
require('sensor-js-message-parsing/controllers/vehicles_controller')
require('sensor-js-message-parsing/controllers/dataset_controller')
require('sensor-js-message-parsing/models/vehicle')
require('sensor-js-message-parsing/models/journey')
require('sensor-js-message-parsing/models/message')
require('sensor-js-message-parsing/models/stop')
