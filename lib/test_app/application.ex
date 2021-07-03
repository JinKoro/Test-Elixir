defmodule TestApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    TestApp.Supervisor.start_link()
  end
end
