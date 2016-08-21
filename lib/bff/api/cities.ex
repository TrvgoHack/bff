defmodule Bff.Api.Cities do
  require Logger

  def get(coords, radius) do
    # coord: lat, lon, radius
    coords = coords
    |> Enum.map(fn coord ->
      Map.put(coord, "radius", radius)
    end)

    query = %{
      coords: coords
    }
    |> :jiffy.encode([:use_nil])

    Logger.debug("Querying cities")
    case HTTPoison.post(url, query, [{"Content-Type", "application/json"}], http_options) do
      {:ok, %{status_code: 200, body: body}} ->
        %{"result" => result} = :jiffy.decode(body, [:return_maps])
        {:ok, result}
      {_, response} ->
        Logger.error("No valid response from Cities API: #{inspect(response)}")
        {:error, :invalid_response}
    end
  end

  defp url do
    "http://#{System.get_env("INDEXER_PORT_4000_TCP_ADDR")}:#{System.get_env("INDEXER_PORT_4000_TCP_PORT")}/cities"
  end

  defp http_options do
    [timeout: @timeout, recv_timeout: @timeout]
  end
end
