defmodule LoadBalancer do
  use GenServer

  def start() do
    GenServer.start_link(__MODULE__, 1, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end


  def handle_info(chunkData, state) do
    Enum.reduce(1..3, %{}, fn pidNum, acc -> Map.put(acc, :"Printer#{pidNum}", Process.info(Process.whereis(:"Printer#{pidNum}"), :message_queue_len ) ) end)
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
