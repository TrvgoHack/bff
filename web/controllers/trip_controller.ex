defmodule Bff.TripController do
  use Bff.Web, :controller

  def cities(conn, %{"origin" => origin, "destination" => destination}) do
    {:ok, coords} = Bff.Api.Routing.get(origin, destination)
    {:ok, cities} = Bff.Api.Cities.get(coords)

    json = cities
    |> :jiffy.encode

    resp(conn, 200, json)
  end
end

