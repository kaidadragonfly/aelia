defmodule Aelia.DeviantArt.HTTP do
  require Logger

  @auth_url Application.fetch_env!(:aelia, :da_auth_url)
  @client_id Application.fetch_env!(:aelia, :da_client_id)
  @client_secret Application.fetch_env!(:aelia, :da_client_secret)

  def type_to_ext("image/jpeg"), do: "jpeg"
  def type_to_ext("image/png"), do: "png"
  def type_to_ext("image/gif"), do: "gif"

  def token_auth() do
    params = %{
      grant_type: "client_credentials",
      client_id: @client_id,
      client_secret: @client_secret
    }

    case fetch(@auth_url, params) do
      {:ok, %{"status" => "success", "access_token" => token}} ->
        {:ok, token}
      error ->
        error
    end
  end

  def fetch(url, params) do
    case get(url, params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
        {_, type} = Enum.find(headers, fn {name, _} -> name == "Content-Type" end)
        if String.starts_with?(type, "application/json") do
          {:ok, Jason.decode!(body)}
        else
          {:ok, body}
        end
      {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
        {:error, "Bad Request: #{body}"}
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, "Unexpected error.  status: #{status} body: #{body}"}
      {:error, %HTTPoison.Error{} = reason} ->
        {:error, "Error: #{HTTPoison.Error.message(reason)}"}
    end
  end

  def fetch_results(url, params, offset \\ 0) do
    params = Map.put(params, :offset, offset)

    case fetch(url, params) do
      {:ok, %{
          "has_more" => true,
          "next_offset" => next_offset,
          "results" => results
       }} ->
        case fetch_results(url, params, next_offset) do
          {:ok, next_results} -> {:ok, results ++ next_results}
          error -> error
        end
      {:ok, %{"has_more" => false, "results" => results}} ->
        {:ok, results}
      error ->
        {:error, error}
    end
  end

  def get(url, params, sleep \\ 100) do
    Logger.info("Requesting url: #{url}")

    case HTTPoison.get(
          url,
          [],
          params: params,
          ssl: [{:versions, [:"tlsv1.3", :"tlsv1.2"]}]) do
      {:ok, %HTTPoison.Response{status_code: 429}} ->
        Process.sleep(sleep)
        get(url, params, 2 * sleep)
      {:ok, resp = %HTTPoison.Response{status_code: 200}} ->
        {:ok, resp}
      resp -> resp
    end
  end
end
