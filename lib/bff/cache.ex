defmodule Bff.Cache do
  require Logger

  @timeout 5_000

  def fetch(key, fun) do
    case read(key) do
      {:ok, :not_found} ->
        case fun.() do
          {:error, result} ->
            Logger.warn("Not caching #{key} due to non OK function result")
            {:error, result}
          {:ok, result} ->
            write(key, result)
            {:ok, result}
        end
      {:ok, result} ->
        {:ok, result}
      _ ->
        nil
    end
  end

  defp read(key) do
    url = "#{url}/default/#{key}"
    case HTTPoison.get(url, [], timeout: @timeout, recv_timeout: @timeout) do
      {:ok, %{status_code: 200, body: body}} ->
        Logger.warn("Got a cache hit! Let's celebrate!")
        result = :jiffy.decode(body, [:return_maps])
        |> Access.get("_source")
        |> Access.get("value")
        |> :jiffy.decode([:return_maps, :use_nil])
        {:ok, result}
      {:ok, %{status_code: 404, body: body}} ->
        Logger.warn("Got a cache miss... Let's wait a while")
        {:ok, :not_found}
      {_, response} ->
        Logger.error("No valid response reading from Elasticsearch cache: #{inspect(response)}")
        {:error, :invalid_response}
    end
  end

  defp write(key, value) do
    url = "#{url}/default/#{key}"
    doc = %{
      value: :jiffy.encode(value, [:use_nil])
    }
    doc = :jiffy.encode(doc, [:use_nil])
    case HTTPoison.post(url, doc, [], timeout: @timeout, recv_timeout: @timeout) do
      {:ok, %{status_code: 200, body: body}} ->
        result = :jiffy.decode(body, [:return_maps])
        {:ok, :exists}
      {:ok, %{status_code: 201, body: body}} ->
        {:ok, :created}
      {_, response} ->
        Logger.error("No valid response writing to Elasticsearch cache: #{inspect(response)}")
        {:error, :invalid_response}
    end
  end

  defp url do
    "http://#{System.get_env("ELASTICSEARCH_PORT_9200_TCP_ADDR")}:#{System.get_env("ELASTICSEARCH_PORT_9200_TCP_PORT")}/cache"
  end
end
