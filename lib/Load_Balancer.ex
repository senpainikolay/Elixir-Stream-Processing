defmodule LoadBalancer do
  use GenServer

  def start(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    childrenCountAll = Supervisor.count_children(PrinterPoolSupervisor)
    len = childrenCountAll.workers
    state = Map.replace(state, "pidCounter", len)
    state = Map.put(state, "currentKillTarget",1)
    {:ok, state}
  end


  def handle_info(chunkData, state) do
    childrenCountAll = Supervisor.count_children(PrinterPoolSupervisor)
    len = childrenCountAll.workers
    Enum.filter(1..len, fn x -> Process.whereis(:"Printer#{x}") != nil end)
    |> Enum.reduce( %{}, fn pidNum, acc ->
      Map.put(acc, :"Printer#{pidNum}", Process.info(Process.whereis(:"Printer#{pidNum}"), :message_queue_len ) )
     end )
    |> Map.to_list()
    |> Enum.min_by(fn {_, minMessageQueueLen} -> minMessageQueueLen end)
    |> elem(0)
    |> Process.whereis
    |> send(chunkData)

    {:noreply, state}
  end


  #  Round Robin fashion.
  # def handle_info(chunkData, state) do
  #   pr = :"Printer#{state}"
  #   state = state + 1
  #   if Process.whereis(pr) == nil do
  #     send(__MODULE__,chunkData)
  #     {:noreply, state}
  #   else
  #   cond do
  #     state >= 4 -> send(pr, chunkData);      {:noreply, 1}
  #     true -> send(pr, chunkData);      {:noreply, state}
  #   end
  # end
  # end


  def handle_cast(:killMessage, state) do
    pr = :"Printer#{ Map.get(state,  "currentKillTarget" )}"
    state = Map.update!(state,  "currentKillTarget", &(&1 + 1))
    if Process.whereis(pr) == nil do
      GenServer.cast(__MODULE__,  :killMessage)
      {:noreply, state}
    else
    cond do
      Map.get(state,  "currentKillTarget") >  Map.get(state,  "pidCounter")  -> GenServer.cast(pr, :killMessage); state = Map.replace(state,  "currentKillTarget", 1);  {:noreply, state}
      true ->  GenServer.cast(pr, :killMessage);    {:noreply, state}
    end
  end
  end

end
