defmodule GossipActor do
  use GenServer

  def init(msg) do
    {:ok, %{"message" => msg, "count" => 0, "neighbors" => []}}
  end

  def handle_cast({:set_neighbors, neighbors}, state) do
    {:noreply, Map.put(state, "neighbors", neighbors)}
  end

  def handle_call({:get_neighbors}, _from, state) do
    {:reply, Map.fetch(state, "neighbors"), state}
  end

  def handle_cast({:transmit_rumor}, state) do
    {:ok, message} = Map.fetch(state, "message")
    {:ok, neighbors} = Map.fetch(state, "neighbors")

    if message != "" && length(neighbors) > 0 do
      _ = GenServer.cast(Enum.random(neighbors), {:receive_rumor, message, self()})
    end

    {:noreply, state}
  end

  def handle_cast({:receive_rumor, rumor, sender}, state) do
    {:ok, count} = Map.fetch(state, "count")

    if count > 10 do
      _ = GenServer.cast(sender, {:terminate_neighbor, self()})
      {:noreply, state}
    else
      # when count<10 increment the counter and set his msg, if
      # But you know what he is incrementing the count even on blank msg :P
      state = Map.put(state, "count", count + 1)
      {:ok, existing_msg} = Map.fetch(state, "message")

      if(existing_msg != "") do
        {:noreply, state}
      else
        {:noreply, Map.put(state, "message", rumor)}
      end
    end
  end

  def handle_cast({:terminate_neighbor, neighbor}, state) do
    {:ok, neighbors} = Map.fetch(state, "neighbors")
    {:noreply, Map.put(state, "neighbors", List.delete(neighbors, neighbor))}
  end

  def handle_call({:get_count}, _from, state) do
    {:reply, Map.fetch(state, "count"), state}
  end

  def handle_call({:get_message}, _from, state) do
    {:reply, Map.fetch(state, "message"), state}
  end

  def handle_call({:get_neighbors_count}, _from, state) do
    {:reply, length(Map.fetch(state, "neighbors")), state}
  end

  def handle_call({:set_message}, _from, state) do
    {:reply, Map.put(state, "message", state)}
  end
end