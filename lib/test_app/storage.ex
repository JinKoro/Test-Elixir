defmodule TestApp.Storage do
  use GenServer

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def put(value, process), do: GenServer.call(__MODULE__, {:put, value, process})

  def get, do: GenServer.call(__MODULE__, :get)

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call(:get, _from, state), do: {:reply, state, state}

  @impl true
  def handle_call({:put, value, process}, _from, state) do
    {:reply, state, Map.put(state, process, value)}
  end
end
