defmodule Printer do
  use GenServer

  def start() do
    min =  5
    max = 50
    lambda = Enum.sum(min..max) / Enum.count(min..max)
    GenServer.start_link(__MODULE__ ,%{lambda: lambda}, name: __MODULE__ )
  end

  def init(state) do
    {:ok, state}
  end

  def handle_info(chunkData, state) do
    IO.inspect(chunkData["message"]["tweet"]["text"])
    val = Statistics.Distributions.Poisson.rand(state[:lambda])
    :timer.sleep(trunc(val))
    {:noreply, state}
  end

end
