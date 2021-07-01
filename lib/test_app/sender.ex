defmodule TestApp.Sender do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  @impl true
  def init(state) do
    start_send()
    {:ok, state}
  end

  @impl true
  def handle_info(:send, state) do
    start_send()
    {:noreply, state}
  end

  def start_send do
    data = DateTime.to_unix(DateTime.utc_now())
    send(data)
    Process.send_after(
      self(),
      :send,
      6000
    )
  end

  @spec send(integer()) :: :ok
  defp send(data) do
    TestApp.Storage.put(data, :process_send)
  end
end
