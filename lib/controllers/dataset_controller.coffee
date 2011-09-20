Sensor.DatasetController = SC.ArrayProxy.extend
  init: ->
    @set('content',[])
  findByDate: (date) ->
    @get('content').find (dataset) ->
      dataset.get('date').toFormattedString('%Y-%m-%d') == date.toFormattedString('%Y-%m-%d')
  findOrCreateByDate: (date) ->
    if dataset = @findByDate(date)
      return dataset
    dataset = Sensor.VehiclesController.create(date: date)
    @pushObject dataset
    dataset
  liveDataset: ( ->
    @get('content').findProperty('liveDataset')
  ).property()



