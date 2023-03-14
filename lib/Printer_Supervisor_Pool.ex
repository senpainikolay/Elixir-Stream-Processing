defmodule PrinterPoolSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__ )
  end

  def init(_) do
    children = [
      %{
        id: :Printer1,
        start: {Printer, :start, [:Printer1]},
        restart: :permanent,
        type: :worker
      },
      %{
        id: :Printer2,
        start: {Printer, :start, [:Printer2]},
        restart: :permanent,
        type: :worker
      },
      %{
        id: :Printer3,
        start: {Printer, :start, [:Printer3]},
        restart: :permanent,
        type: :worker
      }
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end



end
