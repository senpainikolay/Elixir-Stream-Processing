defmodule PrintersAdjuster do
  use GenServer
  def start(_) do
    GenServer.start_link(__MODULE__ , %{}, name: __MODULE__ )
  end

  def init(state) do
    state = Map.put(state, :incomingRequestCounter,0)
    state = Map.put(state, :prevRequestCount,100)
    spawn(fn -> timeout() end )
    {:ok, state}
  end

  def handle_info(:increaseCounter, state) do
    state = Map.update!(state, :incomingRequestCounter,  &(&1 + 1))
    {:noreply, state}
  end

  def handle_call(:timeout,from, state) do
    currentReqs = Map.get(state, :incomingRequestCounter)
    prevRequestsNum =  Map.get(state, :prevRequestCount)
    if  abs(prevRequestsNum - currentReqs) > 200 or currentReqs > 200 do
      childrenCountAll = Supervisor.count_children(PrinterPoolSupervisor)
      if 100 - currentReqs < 0  and childrenCountAll.workers >= 3  do
        Supervisor.start_child(PrinterPoolSupervisor, %{id: String.to_atom("Printer#{childrenCountAll.workers + 1}"), start: {Printer, :start, [String.to_atom("Printer#{childrenCountAll.workers + 1}")]}})
      end

      if 100 - currentReqs > 0 and childrenCountAll.workers >= 3   do
         spawn (fn ->
        childrenCount = childrenCountAll.workers
        GenServer.call(:"Printer#{childrenCount}", :killMessage2)
        end)
      end
    end
    state = Map.replace(state, :incomingRequestCounter, 0)
    state = Map.replace(state, :prevRequestCount, currentReqs)
    spawn(fn -> timeout() end )
    GenServer.reply(from, :ok)
    {:noreply, state}
  end

  def timeout() do
    :timer.sleep(3000)
    GenServer.call(__MODULE__, :timeout )
  end

end
