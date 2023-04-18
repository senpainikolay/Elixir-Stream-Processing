defmodule SwearWordsRemover do
  use GenServer

  def start(name) do
    file_contents = File.read!("swear-words.json")
    {:ok, json_data} = Jason.decode(file_contents)
    GenServer.start_link(__MODULE__ , json_data , name:  name )
  end

  def init(state) do
    {:ok, state}
  end

  #def handle_call(sentence, from,   state) do
  def handle_cast({id, sentence}, state) do
    resp = Enum.map(String.split(sentence),  fn x ->
  if isBad?(x,state) == true do
    " ******"
    else
      " #{x}"
    end
    end)
    GenServer.cast(Aggregator, { id,  List.to_string(resp), 1 })
    #IO.inspect(List.to_string(resp))
    {:noreply, state}
  end


  defp isBad?(word,state) do
    w = String.downcase(word)
    Enum.member?(state,w)
  end


end
