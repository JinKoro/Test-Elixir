defmodule TestApp.Parser do
  use GenServer

  @url "https://www.binance.com/fapi/v1/fundingRate?symbol=BTCUSDT&limit=1"

  @impl true
  def init(state) do
    start_parse()
    {:ok, state}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  @impl true
  def handle_info(:parse, state) do
    start_parse()
    {:noreply, state}
  end

  def start_parse() do
    parse(@url)
    Process.send_after(
      self(),
      :parse,
      10000
    )
  end

  defp parse(url) do
    HTTPoison.start()
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        list = Jason.decode!(body)
        TestApp.Storage.put(
          %{
            funding_time: hd(list)["fundingTime"],
            funding_rate: hd(list)["fundingRate"]
          },
          :process_parse
        )
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end
end
