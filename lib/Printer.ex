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
    respId = GenServer.call(Aggregator, "registerReq")
    sendFrutherToSupervisorPool({ respId, chunkData["message"]["tweet"]["text"]}, "SwearWordsRemover", SwearWordsRemoverPoolSupervisor )
    sendFrutherToSupervisorPool({ respId, chunkData["message"]["tweet"]["text"]}, "SentimentScore", SentimentScorePoolSupervisor )
    sendFrutherToSupervisorPool({respId, chunkData}, "EngagementRatio", EngagementRatioPoolSupervisor )

    val = Statistics.Distributions.Poisson.rand(state[:lambda])
    :timer.sleep(trunc(val))
    {:noreply, state}
  end

  defp sendFrutherToSupervisorPool(chunkData, name, supervisorName) do
   #GenServer.call(supervisorName, chunkData["message"]["tweet"]["text"])
    childrenCountAll = Supervisor.count_children(supervisorName)
    len = childrenCountAll.workers
    Enum.filter(1..len, fn x -> Process.whereis(:"#{name}#{x}") != nil end)
    |> Enum.reduce( %{}, fn pidNum, acc ->
      Map.put(acc, :"#{name}#{pidNum}", Process.info(Process.whereis(:"#{name}#{pidNum}"), :message_queue_len ) )
     end )
    |> Map.to_list()
    |> Enum.min_by(fn {_, minMessageQueueLen} -> minMessageQueueLen end)
    |> elem(0)
    |> Process.whereis
    |> GenServer.cast(chunkData)
  end



  def handle_cast(:killMessage, state) do
    {:stop, :kek, state}
  end

  def handle_cast(:killMessage2, state) do
    {:stop, :kill, state}
  end


end
