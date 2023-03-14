defmodule Lab1 do

  def run do
    #Printer.start
    HashtagExtractor.start
    SSE_READER.start("localhost:4000/tweets/1")
    SSE_READER.start("localhost:4000/tweets/2")
    loop()
  end

  def loop do
    loop()
  end

end
