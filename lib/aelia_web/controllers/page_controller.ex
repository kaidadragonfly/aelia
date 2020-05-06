defmodule AeliaWeb.PageController do
  use AeliaWeb, :controller

  def init(options) do
    HTTPoison.start

    options
  end

  def parse_body(resp) do
    case resp do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode!(body)
      {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
        {:error, "Bad Request: #{body}"}
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, "Unexpected error.  status: #{status} body: #{body}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error: #{reason}"}
    end
  end

  def token_auth do
    url = "https://www.deviantart.com/oauth2/token"
    params = %{
      grant_type: "client_credentials",
      client_id: System.get_env("CLIENT_ID"),
      client_secret: System.get_env("CLIENT_SECRET")
    }

    case parse_body(HTTPoison.get(url, [], params: params)) do
      %{"status" => "success", "access_token" => token} ->
        {:ok, token}
      error ->
        {:error, error}
    end
  end

  def fetch_folders({:ok, token}, username) do
    fetch_folders(token, username, 0)
  end

  def fetch_folders(error), do: error

  def fetch_folders(token, username, offset) do
    Process.sleep(100)
    url = "https://www.deviantart.com/api/v1/oauth2/gallery/folders"
    params = %{
      username: username,
      access_token: token,
      offset: offset,
      # ext_preload: true,
      mature_content: true
    }

    case parse_body(HTTPoison.get(url, [], params: params)) do
      %{
        "has_more" => true,
        "next_offset" => next_offset,
        "results" => results
      } ->
        case fetch_folders(token, username, next_offset) do
          {:ok, next_results} -> {:ok, results ++ next_results}
          error -> error
        end
      %{"has_more" => false, "results" => results} ->
        {:ok, results}
      error ->
        {:error, error}
    end
  end

  def index(conn, _params) do
    folders = token_auth |> fetch_folders("team")
    IO.inspect(folders)

    render(conn, "index.html")
  end
end
