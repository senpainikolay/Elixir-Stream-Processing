defmodule Printer do
  use GenServer

  def start(name) do
    min =  5
    max = 50
    lambda = Enum.sum(min..max) / Enum.count(min..max)
    GenServer.start_link(__MODULE__ ,%{lambda: lambda}, name: name )
  end

  def init(state) do
    {:ok, state}
  end


  def handle_info(chunkData, state) do
    #IO.inspect(chunkData["message"]["tweet"]["text"])
    GenServer.call(SwearWordsRemover, chunkData["message"]["tweet"]["text"])
    |> IO.inspect
    val = Statistics.Distributions.Poisson.rand(state[:lambda])
    :timer.sleep(trunc(val))
    {:noreply, state}
  end



  def handle_cast(:killMessage, state) do
    {:stop, :kek, state}
  end

  def handle_cast(:killMessage2, state) do
    {:stop, :kill, state}
  end


end
