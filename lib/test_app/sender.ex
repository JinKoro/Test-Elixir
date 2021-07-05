defmodule TestApp.Sender do
  @spec start_send :: {:ok, pid}
  def start_send do
    pid = spawn(__MODULE__, :handle_info, [])
    Process.register(pid, :sender)
    send()

    {:ok, pid}
  end

  def handle_info do
    receive do
      pid when is_pid(pid) -> send()
      _ -> IO.inspect("Unexpected message received")
    end

    handle_info()
  end

  defp send do
    data = DateTime.to_unix(DateTime.utc_now())
    TestApp.Storage.put(data, :process_send)

    Process.send_after(
      :sender,
      Process.whereis(:sender),
      6000
    )
  end
end
