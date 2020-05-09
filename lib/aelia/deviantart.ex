defmodule Aelia.DeviantArt do
  def get(url, params, sleep \\ 100) do
    case HTTPoison.get(url, [], params: params) do
      {:ok, %HTTPoison.Response{status_code: 429}} ->
        Process.sleep(sleep)
        get(url, params, 2 * sleep)
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}
      {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
        {:error, "Bad Request: #{body}"}
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, "Unexpected error.  status: #{status} body: #{body}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error: #{reason}"}
    end
  end

  def fetch_results(url, params, offset \\ 0) do
    params = Map.put(params, :offset, offset)

    case get(url, params) do
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

  def token_auth() do
    url = "https://www.deviantart.com/oauth2/token"
    params = %{
      grant_type: "client_credentials",
      client_id: System.get_env("CLIENT_ID"),
      client_secret: System.get_env("CLIENT_SECRET")
    }

    case get(url, params) do
      {:ok, %{"status" => "success", "access_token" => token}} ->
        {:ok, token}
      error -> error
    end
  end

  def fetch_folders(error), do: error

  def fetch_folders(token, username) do
    url = "https://www.deviantart.com/api/v1/oauth2/gallery/folders"
    params = %{
      username: username,
      access_token: token,
      mature_content: true
    }

    fetch_results(url, params)
  end

  def folders(username) do
    {:ok, token} = token_auth()

    folders =
      case fetch_folders(token, username) do
        {:ok, [%{"name" => "Featured", "parent" => nil}|folders]} -> folders
        {:ok, folders} -> folders
      end

    {:ok, Enum.map(folders, &(fetch_folder(token, username, &1)))}
  end

  def fetch_folder(token, username,
    params = %{
      "folderid" => folder_id,
      "name" => name
    }) do
    url =  "https://www.deviantart.com/api/v1/oauth2/gallery/#{folder_id}"
    params = %{
      mode: "newest",
      username: username,
      limit: 24,
      access_token: token,
      mature_content: true
    }

    %{
      name: name,
      contents: fn() ->
        {:ok, contents} = fetch_results(url, params)

        contents
        |> Enum.map(&parse_deviation/1)
        |> Enum.filter(&(Map.get(&1, :file_url)))
      end
    }
  end

  def parse_deviation(
    %{
      "deviationid" => id,
      "title" => title,
      "url" => page_url,
      "is_downloadable" => true,
      "is_deleted" => false,
      "content" => %{"src" => file_url},
      "thumbs" => thumbs
    }) do

    thumb_url = case Enum.find(thumbs,
                      fn(%{"height" => h, "width" => w}) ->
                        w == 100 || h == 100
                      end) do
                  %{"src" => url} -> url
                  nil -> nil
                end

    %{
      id: id,
      title: title,
      page_url: page_url,
      file_url: file_url,
      thumb_url: thumb_url
    }
  end

  def parse_deviation(%{"deviationid" => id}) do
    %{id: id}
  end
end
