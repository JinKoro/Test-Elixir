defmodule TestApp.Parser do
  require Logger

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
      _ -> Logger.debug("Unknown receiving content")
    end

    handle_info()
  end

  defp parse do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(@url),
         [map] <- Jason.decode!(body) do
      TestApp.Storage.put(
        %{
          funding_time: map["fundingTime"],
          funding_rate: map["fundingRate"]
        },
        :process_parse
      )
    else
      {:error, %HTTPoison.Error{reason: reason}} -> Logger.debug(reason)
      _ -> Logger.debug("Unexcepted message recieve")
    end

    Process.send_after(
      :parser,
      Process.whereis(:parser),
      10000
    )
  end
end
