defmodule Bff.Api.Points do
  require Logger

  # response:
  # [{"lng": 6.773769020454545, "lat": 51.22745928257576}, {"lng": 6.773769020454545, "lat": 51.22745928257576}, {"lng": 6.773769020454545, "lat": 51.22745928257576}]

  def get(origin, destination) do
    case HTTPoison.get(url, [], http_options) do
      {:ok, %{status_code: 200, body: body}} ->
        # assume { coords: [ { lat, lon } ] }
        body = :jiffy.decode(body, [:return_maps])
        coords = body
        |> List.first
        |> Enum.map(fn coord ->
          %{
            lat: coord["lat"],
            lon: coord["lng"]
          }
        end)
        {:ok, coords}
      {_, response} ->
        Logger.error("No valid response from Points API: #{inspect(response)}")
        {:error, :invalid_response}
    end
  end

  defp url do
    "http://localhost:4000/dummy/points"
  end

  defp real_url do
    "http://#{System.get_env("ROUTING_PORT_5000_TCP_ADDR")}:#{System.get_env("ROUTING_PORT_5000_TCP_PORT")}/get_points_for_src_dest"
  end

  defp http_options do
    []
  end
end
