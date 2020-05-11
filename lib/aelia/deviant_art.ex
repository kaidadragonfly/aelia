defmodule Aelia.DeviantArt do
  alias Aelia.Repo
  alias Aelia.DeviantArt.{Artist, Folder}

  @base_url "https://www.deviantart.com/api/v1/oauth2"

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
      error -> error
    end
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

  def artist_info(username) do
    case Repo.get(Artist, username) do
      nil -> fetch_artist_info(username)
      %Artist{} = artist -> {:ok, artist}
    end
  end

  defp fetch(url, params, sleep \\ 100) do
    case HTTPoison.get(url, [], params: params) do
      {:ok, %HTTPoison.Response{status_code: 429}} ->
        Process.sleep(sleep)
        fetch(url, params, 2 * sleep)
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

  defp fetch_results(url, params, offset \\ 0) do
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

  defp fetch_artist_info(username) do
    {:ok, token} = token_auth()

    url = "#{@base_url}/user/profile/#{username}"
    params = %{
      username: username,
      access_token: token,
      ext_collections: false,
      ext_galleries: true,
      mature_content: true
    }

    case fetch(url, params) do
      {:ok,
       %{
         "user" => %{"usericon" => icon_url, "userid" => artist_id},
         "profile_url" => profile_url,
         "real_name" => name,
         "galleries" => folders}} ->
        Repo.transaction(fn ->
          {:ok, artist} =
            Repo.insert(
              %Artist{
                id: artist_id,
                name: name,
                username: username,
                profile_url: profile_url,
                icon_url: icon_url
              },
              on_conflict: :replace_all,
              conflict_target: :username
            )

          Enum.each(folders, fn %{"folderid" => id, "name" => name} ->
            Repo.insert(
              %Folder{id: id, name: name, artist_id: artist_id},
              on_conflict: :replace_all,
              conflict_target: :id)
          end)

          artist
        end)
      {:error, message} ->
        case Regex.named_captures(~r/Bad Request: (?<json>.*)/, message) do
          %{"json" => json} ->
            {:error,
             Jason.decode!(json)
             |> Map.get("error_description")
             |> String.capitalize
            }
          nil ->
            {:error, message}
        end
    end
  end

  defp fetch_folders(error), do: error

  defp fetch_folders(token, username) do
    url = "#{@base_url}/gallery/folders"
    params = %{
      username: username,
      access_token: token,
      mature_content: true
    }

    fetch_results(url, params)
  end

  defp fetch_folder(token, username,
    %{
      "folderid" => folder_id,
      "name" => name
    }) do
    url = "#{@base_url}/gallery/#{folder_id}"
    params = %{
      mode: "newest",
      username: username,
      limit: 24,
      access_token: token,
      mature_content: true
    }

    %{
      id: folder_id,
      name: name,
      contents: fn() ->
        {:ok, contents} = fetch_results(url, params)

        contents
        |> Enum.map(&parse_deviation/1)
        |> Enum.filter(&(Map.get(&1, :file_url)))
      end
    }
  end

  defp parse_deviation(
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

  defp parse_deviation(%{"deviationid" => id}) do
    %{id: id}
  end
end
