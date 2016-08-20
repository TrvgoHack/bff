defmodule Bff.Router do
  use Bff.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Bff do
    pipe_through :api
  end
end
