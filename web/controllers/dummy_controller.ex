defmodule Bff.DummyController do
  use Bff.Web, :controller

  def points(conn, params) do
    # [{"lng": 6.773769020454545, "lat": 51.22745928257576}, {"lng": 6.773769020454545, "lat": 51.22745928257576}, {"lng": 6.773769020454545, "lat": 51.22745928257576}]
    points = [
      [
        %{
          lat: 50.89,
          lng: 7.07
        },
        %{
          lat: 50.68,
          lng: 7.62
        }
      ]
    ]
    |> :jiffy.encode([:use_nil])
    resp(conn, 200, points)
  end
end

