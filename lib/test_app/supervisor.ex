defmodule TestApp.Supervisor do
  use Supervisor

  alias TestApp.Storage
  alias TestApp.Parser
  alias TestApp.Sender

  def start_link(opts \\ []) when is_list(opts) do
    opts = [strategy: :one_for_one, name: TestApp.Supervisor]
    Supervisor.start_link(__MODULE__, opts)
  end

  @impl Supervisor
  def init(opts) do
    Supervisor.init(children(), opts)
  end

  defp children do
    [
      storage_child_spec(),
      parser_child_spec(),
      sender_child_spec()
    ]
  end

  defp storage_child_spec do
    %{
      id: Storage,
      start: {Storage, :start_link, []}
    }
  end

  defp parser_child_spec do
    %{
      id: Parser,
      start: {Parser, :start_link, []}
    }
  end

  defp sender_child_spec do
    %{
      id: Sender,
      start: {Sender, :start_link, []}
    }
  end
end
