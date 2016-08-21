defmodule Bff.TripController do
  use Bff.Web, :controller
  require Logger

  def trip(conn, %{"origin" => origin, "destination" => destination, "reach" => reach, "radius" => radius, "day" => day}) do
    {reach, _} = Integer.parse(reach)
    {radius, _} = Integer.parse(radius)
    {day, _} = Integer.parse(day)
    Logger.info("Planning day #{day} of the trip!")

    {:ok, coords} = Bff.Api.Routing.get(origin, destination, reach)
    coords = travel_time(coords, day)

    {:ok, cities} = Bff.Api.Cities.get(coords, radius)
    city = take_city(cities)
    Logger.info("Taking you to #{city["name"]} against your will. Standby")

    wiki = case Bff.Api.Wikipedia.get(city) do
      {:ok, wiki} -> wiki
      {:error, :not_found} -> nil
    end
    {:ok, trivago} = Bff.Api.Trivago.get([city])

    json = render_trip(coords, cities, wiki, trivago)
    |> :jiffy.encode([:use_nil])

    resp(conn, 200, json)
  end

  defp take_city(cities) do
    cities
    |> List.first
    |> Access.get("cities")
    |> List.first
  end

  defp render_trip(coords, cities, wiki, trivago) do
    %{
      coords: coords,
      cities: cities,
      wiki: wiki,
      trivago: trivago
    }
  end

  def travel_time(coords, 0), do: coords
  def travel_time(coords, day) do
    0..(day - 1)
    |> Enum.reduce(coords, fn _, coords ->
      List.delete_at(coords, 0)
    end)
  end
end
