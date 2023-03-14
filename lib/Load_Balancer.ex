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
    send(pr, chunkData)
    state = state + 1
    cond do
      state >= 4 ->   {:noreply, 1}
      true ->    {:noreply, state}
    end
  end
end
