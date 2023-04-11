defmodule GenericSupervisorPool do
  use Supervisor

  def start({name, n}) do
    {moduleName, supervisorName } = infoFactoryMethod(name)
    children = generateChildren(name, moduleName, n)
    Supervisor.start_link(__MODULE__, children, name: supervisorName)
  end

  def init(children) do
    Supervisor.init(children, strategy: :one_for_one,  max_restarts: 10, max_seconds: 10 )
  end

  defp infoFactoryMethod(name) do
    cond  do
      name == "Printer" -> {Printer, PrinterPoolSupervisor }
      name == "SwearWordsRemover" -> { SwearWordsRemover, SwearWordsRemoverPoolSupervisor }
      name == "SentimentScore" -> {SentimentScore, SentimentScorePoolSupervisor }
      name == "EngagementRatio" -> {EngagementRatio, EngagementRatioPoolSupervisor }
    end
  end

  defp generateChildren(name, module, n) do
    Enum.reduce(1..n,
      [],
      fn x, acc -> acc ++
      [%{
          id: :"#{name}#{x}",
          start: {module, :start, [:"#{name}#{x}"]}
        }]
      end  )
  end

end
