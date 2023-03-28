defmodule SwearWordsRemover do
  use GenServer

  def start(_) do
    file_contents = File.read!("swear-words.json")
    {:ok, json_data} = Jason.decode(file_contents)
    GenServer.start_link(__MODULE__ , json_data , name:  __MODULE__ )
  end

  def init(state) do
    {:ok, state}
  end


  def handle_call(sentence, from,   state) do
    resp = Enum.map(String.split(sentence),  fn x ->
  if isBad?(x,state) == true do
    " ******"
    else
      " #{x}"
    end
    end)
    GenServer.reply(from, List.to_string(resp))
    {:noreply, state}
  end


  defp isBad?(word,state) do
    w = String.downcase(word)
    Enum.member?(state,w)
  end


end
