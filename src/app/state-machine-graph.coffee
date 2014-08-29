vtex.curl ['shipping/script/mixin/withShippingStateMachine'], (withShippingStateMachine) ->
  window.mixin = {}
  events = withShippingStateMachine.apply(window.mixin)[1..]
  machine = mixin.createStateMachine()
  mapFrom = (e) -> [e.from, e.to]
  mapNode = (id) -> {data: {id: id, name: id}}
  nodes = _.chain(events).map(mapFrom).flatten().uniq().map(mapNode).value()
  mapEdges = (e) ->
    from = if e.from instanceof Array then e.from else [e.from]
    _.map from, (f) -> {data: { name: e.name, source: f, target: e.to }}
  edges = _.chain(events).map(mapEdges).flatten().value()

  console.log nodes, edges

  window.cy = cytoscape
    container: document.getElementById('state-machine')
    elements:
      nodes: nodes
      edges: edges
    minZoom: 1
    maxZoom: 3
    style: [
      {
        selector: 'node',
        css: {
          'content': 'data(name)',
          'font-family': 'helvetica',
          'font-size': 14,
          'text-outline-width': 3,
          'text-outline-color': '#888',
          'text-valign': 'center',
          'color': '#fff',
          'width': 'mapData(weight, 30, 80, 20, 50)',
          'height': 'mapData(height, 0, 200, 10, 45)',
          'border-color': '#fff'
        }
      },

      {
        selector: ':selected',
        css: {
          'background-color': '#000',
          'line-color': '#000',
          'target-arrow-color': '#000',
          'text-outline-color': '#000'
        }
      },

      {
        selector: 'edge',
        css: {
          'width': 2,
          'color': '#666'
          'content': 'data(name)',
          'target-arrow-shape': 'triangle'
        }
      }
    ]