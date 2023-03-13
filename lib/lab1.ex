defmodule Lab1 do
  @moduledoc """
  Documentation for `Lab1`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Lab1.hello()
      :world

  """
  def run do
    spawn( fn  ->  SSE_READER.start("localhost:4000/tweets/1") end)
    loop()
  end
  def loop do
    loop()
  end

end
