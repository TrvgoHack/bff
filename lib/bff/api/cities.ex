defmodule Bff.Api.Cities do
  require Logger

  @default_radius 50

  def get(coords) do
    # coord: lat, lon, radius
    coords = coords
    |> Enum.map(fn coord ->
      Map.put(coord, "radius", @default_radius)
    end)

    query = %{
      coords: coords
    }
    |> :jiffy.encode([:use_nil])

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
    []
  end
end
