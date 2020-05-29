defmodule Aelia.DeviantArt.HTTP do
  require Logger

  def type_to_ext("image/jpeg"), do: "jpeg"
  def type_to_ext("image/png"), do: "png"
  def type_to_ext("image/gif"), do: "gif"

  def token_auth() do
    url = "https://www.deviantart.com/oauth2/token"
    params = %{
      grant_type: "client_credentials",
      client_id: System.get_env("CLIENT_ID"),
      client_secret: System.get_env("CLIENT_SECRET")
    }

    case fetch(url, params) do
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

    case HTTPoison.get(url, [], params: params) do
      {:ok, %HTTPoison.Response{status_code: 429}} ->
        Process.sleep(sleep)
        get(url, params, 2 * sleep)
      {:ok, resp = %HTTPoison.Response{status_code: 200}} ->
        {:ok, resp}
      resp -> resp
    end
  end
end
