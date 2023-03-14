defmodule LoadBalancer do
  use GenServer

  def start() do
    GenServer.start_link(__MODULE__, 1, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end


  def handle_info(chunkData, state) do
    pr = :"Printer#{state}"
    state = state + 1
    if Process.whereis(pr) == nil do
      send(__MODULE__,chunkData)
      {:noreply, state}
    else
    cond do
      state >= 4 -> send(pr, chunkData);      {:noreply, 1}
      true -> send(pr, chunkData);      {:noreply, state}
    end
  end
  end

  def handle_call(:killMessage,_from, state) do
    pr = :"Printer#{state}"
    state = state + 1
    if Process.whereis(pr) == nil do
      GenServer.call(__MODULE__,:killMessage)
      {:noreply, state}
    else
    cond do
      state >= 4 -> send(pr, :killMessage);  {:noreply, 1}
      true ->   send(pr, :killMessage);    {:noreply, state}
    end
  end
  end

end
