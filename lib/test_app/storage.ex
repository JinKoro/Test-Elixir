defmodule TestApp.Storage do
  use GenServer

  def start_link(table) do
    GenServer.start_link(__MODULE__, table, name: __MODULE__)
  end

  def put(value, process), do: GenServer.call(__MODULE__, {:put, value, process})

  def get, do: GenServer.call(__MODULE__, :get)

  @impl true
  def init(table) do
    name = :ets.new(table, [:named_table])
    {:ok, name}
  end

  @impl true
  def handle_call(:get, _from, table) do
    IO.inspect(table)
    {
      :reply,
      table,
      {
        :ets.lookup(:storage, :process_send),
        :ets.lookup(:storage, :process_parse)
      }
    }
  end

  @impl true
  def handle_call({:put, value, process}, _from, table) do
    :ets.insert(:storage, {process, value})
    IO.inspect(table)
    {:reply, table, table}
  end
end
