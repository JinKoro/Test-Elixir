defmodule TestApp.Parser do
  @url "https://www.binance.com/fapi/v1/fundingRate?symbol=BTCUSDT&limit=1"

  @spec start_parse :: {:ok, pid}
  def start_parse() do
    pid = spawn_link(__MODULE__, :handle_info, [])
    Process.register(pid, :parser)
    parse()

    {:ok, pid}
  end

  def handle_info do
    receive do
      pid when is_pid(pid) -> parse()
      _ -> IO.inspect("Unknown receiving content")
    end

    handle_info()
  end

  defp parse do
    case HTTPoison.get(@url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode!(body) do
          [map] ->
            TestApp.Storage.put(
              %{
                funding_time: map["fundingTime"],
                funding_rate: map["fundingRate"]
              },
              :process_parse
            )

          _ ->
            {:error, "More than one element"}
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  Process.send_after(
    :parser,
    Process.whereis(:parser),
    10000
  )
end
