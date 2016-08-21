defmodule Bff.Api.Wikipedia do
  require Logger

  @timeout 60_000

  def get(%{"name" => name} = city) do
    Bff.Cache.fetch("wikipedia-#{name}", fn ->
      do_get(city)
    end)
  end

  def do_get(%{"name" => name, "coord" => %{"lat" => lat, "lon" => lon}}) do
    location = "#{lat},#{lon}"
    Logger.debug("Loading city information")
    case HTTPoison.get(url, [], params: %{"name" => name, "location" => location}, timeout: @timeout, recv_timeout: @timeout) do
      {:ok, %{status_code: 200, body: body}} ->
        result = :jiffy.decode(body, [:return_maps])
        {:ok, result}
      {:ok, %{status_code: 500, body: body}} ->
        {:error, :not_found}
      {_, response} ->
        Logger.error("No valid response from Wikipedia API: #{inspect(response)}")
        {:error, :invalid_response}
    end
  end

  defp url do
    "http://#{System.get_env("PROPSL_PORT_3000_TCP_ADDR")}:#{System.get_env("PROPSL_PORT_3000_TCP_PORT")}/city"
  end
end
