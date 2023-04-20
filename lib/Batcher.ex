defmodule Batcher do
  use GenServer

  def start(_) do
    GenServer.start_link(__MODULE__ ,%{}, name:  __MODULE__ )
  end

  @spec init(map) :: {:ok, map}
  def init(state) do
    state = Map.put(state, "currentFill", 0)
    state = Map.put(state, "batchSize", 10)
    state = Map.put(state, "printable",  [])
    state = Map.put(state, "currentTimeoutPid",  :ok)

    {:ok, state}
  end

  def handle_cast(:timeoutReset, state ) do
    { _,  existingTweets} = Map.fetch(state, "printable")
      IO.inspect(existingTweets)
      state = Map.replace(state, "printable", [] )
      state = Map.replace(state, "currentFill", 0 )
      {:noreply, state}
  end

  def handle_cast(:callTimeout, state ) do
    pid =
      spawn( fn ->
      :timer.sleep(10)
      GenServer.cast(__MODULE__ , :timeoutReset )
      end)
      state = Map.replace(state, "currentTimeoutPid", pid )
      {:noreply, state}
  end

  def handle_cast(chunkData,  state) do
    { _,  currentSize } = Map.fetch(state, "currentFill")
    { _,  bufferSize } = Map.fetch(state, "batchSize")


    if currentSize == 0 do
      GenServer.cast( self(), :callTimeout)
    end


    cond do

     currentSize >= bufferSize ->
      { _,  existingTweets} = Map.fetch(state, "printable")
      IO.inspect(existingTweets)
      state = Map.replace(state, "printable", [] )
      state = Map.replace(state, "currentFill", 0 )
      {_ ,  currentPid} = Map.fetch(state, "currentTimeoutPid")
      Process.exit(currentPid, :kill)
      {:noreply, state}

    currentSize < bufferSize ->


    {redactedText, sentimentScore,  engagementRatio } = chunkData

    newTweet = redactedText <> "; Sentiment Score: " <>  Float.to_string(sentimentScore) <> "; EngagementRatio: " <> Float.to_string(engagementRatio)

    { _,  existingTweet} = Map.fetch(state, "printable")

    updatedTweets = existingTweet ++ [newTweet]
    state = Map.replace(state, "printable", updatedTweets )

    { _,  currentSize } = Map.fetch(state, "currentFill")
    state = Map.replace(state, "currentFill", currentSize+1 )
    {:noreply, state}
    end

  end


end
