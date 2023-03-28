defmodule HashtagExtractor do
  use GenServer

  def start() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    spawn(fn -> timeout() end )
    {:ok, state}
  end

  def handle_info(chunkData, state) do
    val = chunkData["message"]["tweet"]["entities"]["hashtags"]
    cond do
      val == [] -> {:noreply, state}
      true ->
        newVals = Enum.reduce(val,[], fn x,acc ->  acc ++ [String.trim(x["text"])] end )
        state = state ++ newVals
        {:noreply, state}
      end
  end

  def handle_call(:timeout,_from, state) do
    IO.puts("The popular hashtag status goes to:")
    IO.inspect(popular_hashtag(state))
    spawn(fn -> timeout() end )
    {:noreply, []}
  end


  def timeout() do
    :timer.sleep(5000)
    GenServer.call(__MODULE__, :timeout )
  end

  defp popular_hashtag(hashtags) do
      List.flatten(hashtags)
      |> Enum.reduce(%{}, fn hashtag, acc ->  Map.update(acc, hashtag, 1, fn existing_value  -> existing_value  + 1 end) end)
      |> Map.to_list()
      |> Enum.max_by(fn {_, maxVal} -> maxVal end)
      |> elem(0)
  end
end
