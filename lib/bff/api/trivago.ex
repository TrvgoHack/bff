defmodule Bff.Api.Trivago do
  require Logger

  @timeout 60_000

  def get(cities, max_price \\ 50) do
    city = List.first(cities)
    |> Access.get("name")
    ConCache.get_or_store(:cache, "trivago-#{city}", fn ->
      do_get(city)
    end)
  end

  def do_get(city) do
    Logger.debug("Querying Trivago hotels")
    case HTTPoison.get(url, [], params: %{"origin" => city, "destination" => city}, timeout: @timeout, recv_timeout: @timeout) do
      {:ok, %{status_code: 200, body: body}} ->
        result = :jiffy.decode(body, [:return_maps])
        {:ok, result}
      {_, response} ->
        Logger.error("No valid response from Trivago API: #{inspect(response)}")
        {:error, :invalid_response}
    end
  end

  defp url do
    "http://#{System.get_env("PROPSL_PORT_3000_TCP_ADDR")}:#{System.get_env("PROPSL_PORT_3000_TCP_PORT")}/trip"
  end
end
