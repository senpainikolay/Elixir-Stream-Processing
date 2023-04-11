defmodule SSE_READER do
  use GenServer

  def start(url) do
    GenServer.start_link(__MODULE__, url )
  end

  def init(url) do
    IO.puts "Connecting to stream..."
    HTTPoison.get!(url, [], [recv_timeout: :infinity, stream_to: self()])
    {:ok, nil}
  end


  def handle_info(%HTTPoison.AsyncEnd{id: _}, state) do
    IO.puts("AAAAAAAAAAUUUUUUUUUUUUUUUUUUUUUUUUUUFFFFFFFFFFFFFFFFFfffff")
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: ""}, state) do
    GenServer.cast(LoadBalancer, :killMessage)
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, state) do
    [_,data] =  Regex.run(~r/data: ({.+})\n\n$/, chunk)
    case Jason.decode(data) do
      {:ok, chunkData} ->
        send(LoadBalancer, chunkData)
        send(HashtagExtractor, chunkData)
        send(PrintersAdjuster, :increaseCounter)
      {:error, _ } -> GenServer.cast(LoadBalancer, :killMessage); nil; {:noreply, state}

    end
    {:noreply, state}
  end


  def handle_info(%HTTPoison.AsyncStatus{} = status, state) do
    IO.puts "Connection status: #{inspect status}"
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncHeaders{} = headers, state) do
    IO.puts "Connection headers: #{inspect headers}"
    {:noreply, state}
  end



end
