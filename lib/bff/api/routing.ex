defmodule Bff.Api.Routing do
  require Logger

  @timeout 60_000

  def get(origin, destination, reach) do
    reach = reach * 1000
    Bff.Cache.fetch("routing-#{origin}-#{destination}-#{reach}", fn ->
      do_get(origin, destination, reach)
    end)
  end

  defp do_get(origin, destination, reach) do
    Logger.debug("Calculating route")
    case HTTPoison.get(real_url, [], params: %{"start" => origin, "end" => destination, "reach" => reach}, timeout: @timeout, recv_timeout: @timeout) do
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
        Logger.error("No valid response from Routing API: #{inspect(response)}")
        {:error, :invalid_response}
    end
  end

  defp url do
    "http://localhost:4000/dummy/points"
  end

  defp real_url do
    "http://#{System.get_env("ROUTING_PORT_5000_TCP_ADDR")}:#{System.get_env("ROUTING_PORT_5000_TCP_PORT")}/intervals"
  end
end
