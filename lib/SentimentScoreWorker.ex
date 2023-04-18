defmodule SentimentScore do
  use GenServer

  def start(name) do
    url = "localhost:4000/emotion_values"
    %{body: response} = HTTPoison.get!(url)
    emoationalScoreMap =
      response
      |> String.split("\r")
      |> Enum.map( fn x  -> String.replace(x,"\n", "") end)
      |> Enum.map( fn x  -> String.split(x,"\t") end)
      |> Enum.reduce( %{}, fn x, acc  -> Map.put(acc, List.first(x), parseInt(x))  end)
    GenServer.start_link(__MODULE__ , emoationalScoreMap , name:  name )
  end

  defp parseInt(b) do
    {val, _ } = Integer.parse(List.last(b))
    abs(val)
  end

  def init(state) do
    {:ok, state}
  end


  def handle_cast({id, sentence},  state) do
    resp =
    Enum.map( String.split(sentence),  fn x ->
    val = state[x]
     cond do
      val == nil -> 0
      true -> val
     end
    end)
    #IO.puts("MEAN EMOTIONAL SCORE:")
    GenServer.cast(Aggregator, { id,  Enum.sum(resp) / Enum.count(resp) , 2 })
    #IO.inspect( Enum.sum(resp) / Enum.count(resp) )
    {:noreply, state}
  end




end
