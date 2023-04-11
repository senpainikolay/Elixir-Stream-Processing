defmodule Lab1 do

  def run do
    children = [
      %{
        id: :SwearWordsRemover,
        start: {SwearWordsRemover, :start,  [:ok] }
      },
      %{
        id: :PrinterSupervisor,
        start: {GenericSupervisorPool, :start, [ { "Printer", 3 } ]},
        type: :supervisor
      },
      %{
        id: :LoadBalancer,
        start: {LoadBalancer, :start,  [%{"pidCounter" => 3}] }
      },
      %{
        id: :HashTahEx,
        start: {HashtagExtractor, :start, []}
      },
      %{
        id: :SSE_READER1,
        start: {SSE_READER, :start, ["localhost:4000/tweets/1"]}
      },
      %{
        id: :SSE_READER2,
        start: {SSE_READER, :start, ["localhost:4000/tweets/2"]}
      },
      %{
        id: :WorkerPoolAdjuster,
        start: {PrintersAdjuster, :start, [:ok]}
      }
    ]

    {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one, max_restarts: 10, max_seconds: 10 )


    loop()
  end

  def loop do
    loop()
  end

end
