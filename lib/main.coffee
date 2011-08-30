require('sproutcore-runtime')
require('sproutcore-datetime')
Sensor ?= SC.Application.create()
Sensor.IGNITION_ON = 64
Sensor.IGNITION_OFF = 65
Sensor.MOVING = 333
require('sensor-js-message-parsing/collections/journeys')
require('sensor-js-message-parsing/models/vehicle')
require('sensor-js-message-parsing/models/journey')
require('sensor-js-message-parsing/models/message')
require('sensor-js-message-parsing/models/stop')
require('sensor-js-message-parsing/underscore')
