defmodule Bff.Router do
  use Bff.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Bff do
    pipe_through :api

    get "/trip", TripController, :show
    get "/dummy/points", DummyController, :points
  end
end
