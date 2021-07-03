defmodule TestApp.Parser do
  @url "https://www.binance.com/fapi/v1/fundingRate?symbol=BTCUSDT&limit=1"

  def start_parse() do
    Process.send_after(
      spawn(__MODULE__, :handle_info, []),
      :ok,
      10000
    )

    {:ok, self()}
  end

  def handle_info do
    receive do
      :ok -> parse(@url)
      _ -> raise "Unknown receiving content"
    end

    start_parse()
  end

  defp parse(url) do
    case HTTPoison.get(url) do
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
end
