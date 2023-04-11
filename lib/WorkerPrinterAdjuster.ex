defmodule PrintersAdjuster do
  use GenServer
  def start(_) do
    GenServer.start_link(__MODULE__ , 0, name: __MODULE__ )
  end

  def init(state) do
    spawn(fn -> timeout() end )
    {:ok, state}
  end

  def handle_info(:increaseCounter, state) do
    state = state + 1
    {:noreply, state}
  end

  def handle_info( :timeout, state) do
    childrenCountAll = Supervisor.count_children(PrinterPoolSupervisor)
    IO.inspect(childrenCountAll)
    IO.inspect("CURRENTTTT REQSS:::")
    IO.puts(state)
    if state > 500   and childrenCountAll.workers >= 3  do
      Supervisor.start_child(PrinterPoolSupervisor, %{id: String.to_atom("Printer#{childrenCountAll.workers + 1}"), start: {Printer, :start, [String.to_atom("Printer#{childrenCountAll.workers + 1}")]}})
    end
    if state < 500 and childrenCountAll.workers >= 3   do
      childrenCount = childrenCountAll.workers;
      GenServer.cast(:"Printer#{childrenCount}", :killMessage2)
    end
    spawn(fn -> timeout() end )
    state = 0
    {:noreply, state}
  end

  def timeout() do
    :timer.sleep(3000)
    send(__MODULE__, :timeout )
  end

end
