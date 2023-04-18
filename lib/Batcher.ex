defmodule Batcher do
  use GenServer

  def start(_) do
    GenServer.start_link(__MODULE__ ,%{}, name:  __MODULE__ )
  end

  @spec init(map) :: {:ok, map}
  def init(state) do
    state = Map.put(state, "currentFill", 0)
    state = Map.put(state, "batchSize", 50)
    state = Map.put(state, "printable",  [])
    {:ok, state}
  end

  def handle_cast(chunkData,  state) do
    { _,  currentSize } = Map.fetch(state, "currentFill")
    { _,  bufferSize } = Map.fetch(state, "batchSize")

    cond do

     currentSize >= bufferSize ->
      { _,  existingTweets} = Map.fetch(state, "printable")
      IO.inspect(existingTweets)
      state = Map.replace(state, "printable", [] )
      state = Map.replace(state, "currentFill", 0 )
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
