defmodule Batcher do
  use GenServer

  def start(_) do
    GenServer.start_link(__MODULE__ , %{} , name:  __MODULE__ )
  end

  def init(state) do
    {:ok, state}
  end


  def handle_info(chunkData,  state) do
    {:noreply, state}
  end




end
