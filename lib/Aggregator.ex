defmodule Aggregator do
  use GenServer

  def start(_) do
    GenServer.start_link(__MODULE__ , %{} , name:  __MODULE__ )
  end

  def init(state) do
    state = Map.put(state, 0, {-1,-1, -1} )

    {:ok, state}
  end

  def handle_call("registerReq", _, state) do
    resp =
      Map.keys(state)
      |> Enum.sort()
      |> Enum.take(-1)
      |> List.first()

    state = Map.put(state, resp+1, { -1, -1, -1} )
    {:reply, resp+1,  state}
  end

  def handle_cast({id, newData, i} ,  state) do
    {redactedText, sentimentScore,  engagementRatio }   = Map.get(state, id)
    state =
    cond do
      i == 1 ->  Map.replace(state, id,  {  newData, sentimentScore,  engagementRatio }  )
      i == 2 ->  Map.replace(state, id,  {  redactedText, newData,  engagementRatio }  )
      i == 3 ->  Map.replace(state, id,  {  redactedText, sentimentScore,  newData }  )
    end

    {redactedText, sentimentScore,  engagementRatio }   = Map.get(state, id)
    if redactedText != -1  and sentimentScore != -1  and engagementRatio != -1 do
        IO.inspect("DONEEEEEe")
        # Send To Batcher
    end

    {:noreply, state}
  end



end
