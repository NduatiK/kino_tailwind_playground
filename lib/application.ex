defmodule KinoTailwindPlayground.Application do
  use Application

  def start(_type, _args) do
    Kino.SmartCell.register(KinoTailwindPlayground)

    children = []
    opts = [strategy: :one_for_one, name: KinoTailwindPlayground.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
