defmodule Lab1 do

  def run do
    Printer.start
    spawn( fn  ->  SSE_READER.start("localhost:4000/tweets/1") end)
    spawn( fn  ->  SSE_READER.start("localhost:4000/tweets/2") end)
    loop()
  end

  def loop do
    loop()
  end

end
