defmodule Bff.Api.Cities do
  require Logger

  def get(coords, radius) do
    coords = coords
    |> Enum.map(fn coord ->
      Map.put(coord, "radius", radius)
    end)

    query = %{
      coords: coords
    }
    |> :jiffy.encode([:use_nil])

    Logger.debug("Querying cities by coords")
    url = url <> "/by_coords"
    case HTTPoison.post(url, query, [{"Content-Type", "application/json"}], http_options) do
      {:ok, %{status_code: 200, body: body}} ->
        %{"result" => result} = :jiffy.decode(body, [:return_maps])
        {:ok, result}
      {_, response} ->
        Logger.error("No valid response from Cities API: #{inspect(response)}")
        {:error, :invalid_response}
    end
  end

  def get_by_name(name) do
    Logger.debug("Querying cities by name")
    url = url <> "/by_name"
    case HTTPoison.get(url, [{"Content-Type", "application/json"}], params: %{name: name}, timeout: @timeout, recv_timeout: @timeout) do
      {:ok, %{status_code: 200, body: body}} ->
        %{"cities" => cities} = :jiffy.decode(body, [:return_maps])
        {:ok, cities}
      {_, response} ->
        Logger.error("No valid response from Cities API: #{inspect(response)}")
        {:error, :invalid_response}
    end
  end

  defp url do
    "http://#{System.get_env("INDEXER_PORT_4000_TCP_ADDR")}:#{System.get_env("INDEXER_PORT_4000_TCP_PORT")}"
  end

  defp http_options do
    [timeout: @timeout, recv_timeout: @timeout]
  end
end
