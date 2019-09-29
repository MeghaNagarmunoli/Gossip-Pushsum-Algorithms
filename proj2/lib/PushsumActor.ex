defmodule PushsumActor do
  use GenServer

  def init(pushsum_state) do
    {:ok,
     %{
       "s" => Enum.at(pushsum_state, 0),
       "w" => 1,
       "diff1" => 1,
       "diff2" => 1,
       "diff3" => 1,
       "triggered" => Enum.at(pushsum_state, 1),
       "neighbors" => [],
       # this is to carry actor name in the state to persist, might replace self()
       "name" => Enum.at(pushsum_state, 2)
     }}
  end

  def handle_cast({:set_neighbors, neighbors}, state) do
    {:noreply, Map.put(state, "neighbors", neighbors)}
  end

  def handle_call({:get_neighbors}, _from, state) do
    {:reply, Map.fetch(state, "neighbors"), state}
  end

  def handle_cast({:transmit_values}, state) do
    {:ok, s} = Map.fetch(state, "s")
    {:ok, w} = Map.fetch(state, "w")
    {:ok, triggered} = Map.fetch(state, "triggered")
    {:ok, neighbors} = Map.fetch(state, "neighbors")

    if length(neighbors) > 0 && triggered != 0 do
      # because of self() and the name conflict, it messes up here
      {:ok, actor_name} = Map.fetch(state, "name")
      _ = GenServer.cast(Enum.random(neighbors), {:receive_values, s / 2, w / 2, actor_name})
    end

    {:noreply, state}
  end

  def handle_cast({:receive_values, s_recvd, w_recvd, sender}, state) do
    {:ok, diff1} = Map.fetch(state, "diff1")
    {:ok, diff2} = Map.fetch(state, "diff2")
    {:ok, diff3} = Map.fetch(state, "diff3")

    # if three consecutive differences are less than 10 power -10 terminate the actor
    if diff1 < :math.pow(10, -10) && diff2 < :math.pow(10, -10) && diff3 < :math.pow(10, -10) do
      # because of self() and the name conflict, it messes up here
      {:ok, actor_name} = Map.fetch(state, "name")
      _ = GenServer.cast(sender, {:terminate_neighbor, actor_name})
      {:noreply, state}
    else
      # fetching current values and updating them
      {:ok, s_cur} = Map.fetch(state, "s")
      {:ok, w_cur} = Map.fetch(state, "w")
      s_new = s_cur + s_recvd
      w_new = w_cur + w_recvd

      diff1 = diff2
      diff2 = diff3
      cur_ratio = s_cur / w_cur
      new_ratio = s_new / w_new
      diff3 = abs(cur_ratio - new_ratio)

      # To keep half the value and send the other half
      # s_new = s_new / 2
      # w_new = w_new / 2

      state = Map.put(state, "s", s_new)
      state = Map.put(state, "w", w_new)
      state = Map.put(state, "diff1", diff1)
      state = Map.put(state, "diff2", diff2)
      state = Map.put(state, "diff3", diff3)
      state = Map.put(state, "triggered", 1)
      {:noreply, state}
    end
  end

  def handle_cast({:terminate_neighbor, neighbor}, state) do
    {:ok, neighbors} = Map.fetch(state, "neighbors")
    {:noreply, Map.put(state, "neighbors", List.delete(neighbors, neighbor))}
  end

  def handle_call({:check_alive}, _from, state) do
    {:ok, diff1} = Map.fetch(state, "diff1")
    {:ok, diff2} = Map.fetch(state, "diff2")
    {:ok, diff3} = Map.fetch(state, "diff3")

    # This syntax might be wrong
    if abs(diff1) > :math.pow(10, -10) || abs(diff2) > :math.pow(10, -10) ||
         abs(diff3) > :math.pow(10, -10) do
      {:reply, true, state}
    else
      {:reply, false, state}
    end
  end

  def handle_call({:set_message}, _from, state) do
    {:reply, Map.put(state, "message", state)}
  end

  # def set_neighbors(actor, neighbors) do
  #   GenServer.cast(actor, {:set_neighbors, neighbors})
  # end
end