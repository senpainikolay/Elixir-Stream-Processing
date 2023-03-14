defmodule SSE_READER do
  use GenServer

  def start(url) do
    GenServer.start_link(__MODULE__, url)
  end

  def init(url) do
    IO.puts "Connecting to stream..."
     HTTPoison.get!(url, [], [recv_timeout: :infinity, stream_to: self()])
    {:ok, nil}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, state) do
    [_,data] =  Regex.run(~r/data: ({.+})\n\n$/, chunk)
    case Jason.decode(data) do
      {:ok, chunkData} ->
        #IO.inspect(chunkData["message"]["tweet"]["text"])
        send(LoadBalancer, chunkData)
        #send(Printer, chunkData)
        #:timer.sleep(1000)
      {:error, _ } -> nil
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

  def handle_call(:killMessageTrigger,_from, state) do
    spawn(fn -> killMe() end )
    GenServer.call(LoadBalancer, :killMessage)
    {:noreply, state}
  end

  defp killMe() do
    :timer.sleep(:rand.uniform(5000) + 3000)
    GenServer.call(__MODULE__, :killMessageTrigger )
  end


end
