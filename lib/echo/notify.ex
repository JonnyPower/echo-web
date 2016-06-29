defmodule Echo.Notify do
  use Supervisor

  alias Echo.GCMWorker

  def start_link do
    Supervisor.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init([]) do
    children = [
      worker(GCMWorker, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

end