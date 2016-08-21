defmodule Bff.Api.Trivago do
  require Logger

  @timeout 30_000

  def get(cities, max_price) do
    Bff.Cache.fetch("trivago-#{cache_key(cities)}-#{max_price}", fn ->
      do_get(cities, max_price)
    end)
  end

  def do_get(cities, max_price) do
    city_names = cities
    |> Enum.map(&Access.get(&1, "name"))

    Logger.debug("Querying Trivago hotels in #{city_names |> Enum.join(",")} for a maximum price of #{max_price}€")

    query = %{
      cities: city_names
    }
    |> :jiffy.encode([:use_nil])

    case HTTPoison.post(url, query, [{"Content-Type", "application/json"}], timeout: @timeout, recv_timeout: @timeout) do
      {:ok, %{status_code: 200, body: body}} ->
        result = :jiffy.decode(body, [:return_maps])
        {:ok, result}
      {:ok, %{status_code: 404}} ->
        {:error, :not_found}
      {:error, %HTTPoison.Error{reason: :timeout}} ->
        {:error, :timeout}
      {_, response} ->
        Logger.error("No valid response from Trivago API: #{inspect(response)}")
        {:error, :invalid_response}
    end
  end

  defp url do
    "http://#{System.get_env("PROPSL_PORT_3000_TCP_ADDR")}:#{System.get_env("PROPSL_PORT_3000_TCP_PORT")}/trip"
  end

  defp cache_key(cities) do
    cities
    |> Enum.map(&Access.get(&1, "name"))
    |> Enum.join("-")
  end
end
