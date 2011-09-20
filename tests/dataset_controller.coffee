controller = null
module "Dataset Controller",
  setup: ->
    controller = Sensor.DatasetController.create()


test ".findOrCreateByDate", ->
  dataset = controller.findOrCreateByDate(SC.DateTime.create())
  ok dataset, "returns a dataset"
  equals controller.findOrCreateByDate(SC.DateTime.create()), dataset, "returns preexisting datasets"

test ".liveDataset", ->
  equals controller.get('liveDataset'), undefined
  liveDataset = Sensor.VehiclesController.create(date:SC.DateTime.create())
  oldDataset  = Sensor.VehiclesController.create(date:SC.DateTime.create().advance(day: -1))
  controller.pushObject liveDataset
  controller.pushObject oldDataset
  equals controller.get('liveDataset'), liveDataset, "returns the live dataset"


