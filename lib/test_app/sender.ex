defmodule TestApp.Sender do
  @spec start_send :: {:ok, pid}
  def start_send do
    Process.send_after(
      spawn(__MODULE__, :handle_info, []),
      :ok,
      6000
    )

    {:ok, self()}
  end

  def handle_info do
    receive do
      :ok -> send()
      _ -> raise "Unknown receiving content"
    end

    start_send()
  end

  defp send do
    data = DateTime.to_unix(DateTime.utc_now())
    TestApp.Storage.put(data, :process_send)
  end
end
