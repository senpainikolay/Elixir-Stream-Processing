defmodule Lab1 do

  def run do
    # PrinterPoolSupervisor.start_link()
    # HashtagExtractor.start
    # #LoadBalancer.start
    # SSE_READER.start("localhost:4000/tweets/1")
    # SSE_READER.start("localhost:4000/tweets/2")
    children = [
      %{
        id: Ok1,
        start: {PrinterPoolSupervisor, :start_link, []},
        type: :supervisor
      },
      %{
        id: :LoadBalancer,
        start: {LoadBalancer, :start, []  }
      },
      %{
        id: Ok2,
        start: {HashtagExtractor, :start, []}
      },
      %{
        id: Ok3,
        start: {SSE_READER, :start, ["localhost:4000/tweets/1"]}
      },
      %{
        id: Ok4,
        start: {SSE_READER, :start, ["localhost:4000/tweets/2"]}
      }
    ]

    # Now we start the supervisor with the children and a strategy
    {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)

    loop()
  end

  def loop do
    loop()
  end

end
