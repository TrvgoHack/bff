defmodule Bff.TripController do
  use Bff.Web, :controller

  def cities(conn, %{"origin" => origin, "destination" => destination, "reach" => reach, "radius" => radius}) do
    {reach, _} = Integer.parse(reach)
    {radius, _} = Integer.parse(radius)
    {:ok, coords} = Bff.Api.Routing.get(origin, destination, reach)
    {:ok, cities} = Bff.Api.Cities.get(coords, radius)

    json = cities
    |> :jiffy.encode

    resp(conn, 200, json)
  end
end

