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
    cities = todays_cities(cities)

    cities = Enum.take(cities, 2)
    {:ok, trivago} = Bff.Api.Trivago.get(cities)
    trivago = amend_wiki(trivago)

    json = render_trip(coords, cities, trivago)
    |> :jiffy.encode([:use_nil])

    resp(conn, 200, json)
  end

  defp todays_cities(cities) do
    cities
    |> List.first
    |> Access.get("cities")
  end

  defp render_trip(coords, cities, trivago) do
    %{
      coords: coords,
      cities: cities,
      trivago: trivago
    }
  end

  defp travel_time(coords, 0), do: coords
  defp travel_time(coords, day) do
    0..(day - 1)
    |> Enum.reduce(coords, fn _, coords ->
      List.delete_at(coords, 0)
    end)
  end

  defp amend_wiki(trivago) do
    trivago
    |> Enum.map(fn hotel ->
      name = hotel["city"]
      {:ok, cities} = Bff.Api.Cities.get_by_name(name)
      city = List.first(cities)
      case Bff.Api.Wikipedia.get(city) do
        {:ok, wiki} ->
          Map.put(hotel, "wiki", wiki)
        _ ->
          Map.put(hotel, "wiki", %{
            summary: "No Wikipedia article found for #{city}",
            image: nil
          })
      end
    end)
  end
end
