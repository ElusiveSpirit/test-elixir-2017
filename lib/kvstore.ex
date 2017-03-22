defmodule KVstore do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec
    port = Application.get_env(:example, :cowboy_port, 4000)

    children = [
      worker(KVstore.Storage, []),
      Plug.Adapters.Cowboy.child_spec(:http, KVstore.Router, [], port: port)
    ]

    Logger.info "Application started"

    opts = [strategy: :one_for_one, name: KVstore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

