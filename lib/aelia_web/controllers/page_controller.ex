defmodule AeliaWeb.PageController do
  use AeliaWeb, :controller

  def init(options) do
    HTTPoison.start

    options
  end

  def token_auth do
    url = "https://www.deviantart.com/oauth2/token"
    params = %{
      grant_type: "client_credentials",
      client_id: System.get_env("CLIENT_ID"),
      client_secret: System.get_env("CLIENT_SECRET")
    }

    case HTTPoison.get(url, [], params: params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode!(body) do
          %{"status" => "success", "access_token" => token} ->
            {:ok, token}
          error ->
            {:error, error}
        end
      {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
        {:error, "Bad Request: #{body}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error: #{reason}"}
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, "Unexpected error.  status: #{status} body: #{body}"}
    end
  end

  def fetch_folders({:ok, token}, username) do
    url = "https://www.deviantart.com/api/v1/oauth2/gallery/folders"
    params = %{
      username: username,
      access_token: token
    }

    IO.inspect(HTTPoison.get(url, [], params: params))
  end

  def fetch_folders(error), do: error

  def index(conn, _params) do
    token = token_auth |> fetch_folders("team")

    render(conn, "index.html")
  end
end
