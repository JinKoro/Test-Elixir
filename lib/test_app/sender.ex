defmodule TestApp.Sender do
  require Logger

  @spec start_send :: {:ok, pid}
  def start_send do
    pid = spawn_link(__MODULE__, :handle_info, [])
    Process.send(pid, :send_request, [])

    {:ok, pid}
  end

  def handle_info do
    receive do
      :send_request -> send()
      _ -> Logger.debug("Unexpected message received")
    end

    handle_info()
  end

  defp send do
    data = DateTime.to_unix(DateTime.utc_now())
    TestApp.Storage.put(data, :process_send)

    Process.send_after(
      self(),
      :send_request,
      6000
    )
  end
end
