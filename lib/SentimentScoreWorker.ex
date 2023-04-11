defmodule SentimentScore do
  use GenServer

  def start(_) do
    url = "localhost:4000/emotion_values"
    %{body: response} = HTTPoison.get!(url)
    emoationalScoreMap =
      response
      |> String.split("\r")
      |> Enum.map( fn x  -> String.replace(x,"\n", "") end)
      |> Enum.map( fn x  -> String.split(x,"\t") end)
      |> Enum.reduce( %{}, fn x, acc  -> Map.put(acc, List.first(x), parseInt(x))  end)
    GenServer.start_link(__MODULE__ , emoationalScoreMap , name:  __MODULE__ )
  end

  defp parseInt(b) do
    {val, _ } = Integer.parse(List.last(b))
    abs(val)
  end

  def init(state) do
    {:ok, state}
  end


  def handle_call(sentence, from,   state) do
    {:noreply, state}
  end




end
