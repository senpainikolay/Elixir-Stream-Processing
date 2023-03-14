defmodule Lab1 do

  def run do
    PrinterPoolSupervisor.start_link()
    HashtagExtractor.start
    SSE_READER.start("localhost:4000/tweets/1")
    SSE_READER.start("localhost:4000/tweets/2")

    loop()
  end

  def loop do
    loop()
  end

end
