defmodule Utils do
  # "getNeighbour" might be an appropriate name here
  def get_neighbors(actors, topology) do
    case topology do
      "line" ->
        Topology.line(actors)
      "full" ->
        Topology.get_full_neighbors(actors)
        # "rand2D" -> numNodes
      "3Dtorus" ->
        Topology.get_3Dtorus_neighbours(actors)
      "honeycomb" ->
        Topology.get_honeycomb_neighbours(actors)
      "randhoneycomd" ->
        Topology.get_randhoneycomb_neighbours(actors)
    end
  end

  def node_correction(num_nodes,topology) do
    case topology do
        "line" ->
          num_nodes
        "full" ->
          num_nodes
        "rand2D" ->
          num_nodes
        "3Dtorus" ->
          num_nodes = get_next_cube(1,num_nodes)
        "honeycomb" ->
           num_nodes
        "randhoneycomd" ->
          num_nodes
    end
  end

  def get_next_cube(i,numNodes) do
    test = (i*i*i)<numNodes
    if test do
      get_next_cube(i+1,numNodes)
    else
      i*i*i
    end
  end

  def findCubeRoot(i,numNodes) do
    test = (i*i*i) == numNodes
    if test do
      i
    else
      get_next_cube(i+1,numNodes)
    end
  end
end
