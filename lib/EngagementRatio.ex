defmodule EngagementRatio do
  use GenServer

  def start(name) do
    GenServer.start_link(__MODULE__ , :ok , name:  name )
  end

  def init(state) do
    {:ok, state}
  end


  def handle_cast({id, chunkData},  state) do
    val = chunkData["message"]["tweet"]["retweeted_status"]["favorite_count"]
    fav =
      cond do
        val == nil -> 0
        true -> val
      end
    val = chunkData["message"]["tweet"]["retweeted_status"]["retweet_count"]
    ret =
      cond do
        val == nil -> 0
        true -> val
      end


    followers = chunkData["message"]["tweet"]["user"]["followers_count"]

    engagementRatio =
    cond do
      followers == 0 -> 0
      true -> (fav + ret) / followers
    end

    #IO.puts("ENGAGEMENT RATIO:  ")
    #IO.inspect(engagementRatio)
    GenServer.cast(Aggregator, { id, engagementRatio , 3 })
    {:noreply, state}
  end




end
