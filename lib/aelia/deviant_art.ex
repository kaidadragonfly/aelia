defmodule Aelia.DeviantArt do
  alias Aelia.Repo
  alias Aelia.DeviantArt.{Artist, Folder, Work}

  import Ecto.Query, only: [from: 2]

  @base_url "https://www.deviantart.com/api/v1/oauth2"

  def artist_info(username) do
    case Repo.get_by(Artist, username: username) do
      nil -> refresh_artist_info(username)
      %Artist{} = artist -> {:ok, preload_folders(artist)}
    end
  end

  def folder(id) do
    Repo.get!(Folder, id) |> Repo.preload(:artist) |> refresh_folder
  end

  defp token_auth() do
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

  defp get(url, params, sleep \\ 100) do
    case HTTPoison.get(url, [], params: params) do
      {:ok, %HTTPoison.Response{status_code: 429}} ->
        Process.sleep(sleep)
        get(url, params, 2 * sleep)
      {:ok, resp = %HTTPoison.Response{status_code: 200}} ->
        {:ok, resp}
      resp -> resp
    end
  end

  defp fetch(url, params) do
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

  defp preload_folders(%Artist{} = artist) do
    query = from f in Folder, where: is_nil(f.parent_id), order_by: f.index

    artist
    |> Repo.preload(folders: query)
    |> Repo.preload(folders: [children: from(f in Folder, order_by: f.index)])
  end

  defp refresh_artist_info(username) do
    {:ok, token} = token_auth()

    url = "#{@base_url}/user/profile/#{username}"
    params = %{
      username: username,
      access_token: token,
      ext_collections: false,
      ext_galleries: false,
      mature_content: true
    }

    case fetch(url, params) do
      {:ok,
       %{
         "user" => %{"usericon" => icon_url, "userid" => id},
         "profile_url" => profile_url,
         "real_name" => name}} ->
        Repo.transaction(fn ->
          {:ok, artist} =
            Repo.insert(
              %Artist{
                id: id,
                name: name,
                username: username,
                profile_url: profile_url,
                icon_url: icon_url
              },
              on_conflict: :replace_all,
              conflict_target: :username
            )

          refresh_folders(token, id, username)

          preload_folders(artist)
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

  defp refresh_folders(token, artist_id, username) do
    url = "#{@base_url}/gallery/folders"
    params = %{
      username: username,
      access_token: token,
      mature_content: true
    }

    {:ok, folders} = fetch_results(url, params)

    %{"folderid" => featured_id} =
      Enum.find(folders, fn f -> Map.get(f, "name") == "Featured" end)

    folders
    |> Enum.with_index
    |> Enum.each(
    fn {%{"folderid" => id, "name" => name, "parent" => parent_id}, index} ->
      parent_id =
      if parent_id == featured_id do
        nil
      else
        parent_id
      end

      Repo.insert(
        %Folder{id: id,
                name: name,
                artist_id: artist_id,
                parent_id: parent_id,
                index: index},
        on_conflict: :replace_all,
        conflict_target: :id)
    end)
  end

  defp get_folder(id) do
    works_query = from w in Work, order_by: w.index
    folder = Repo.one from f in Folder,
      where: f.id == ^id,
      preload: [works: ^works_query],
      preload: :artist

    {:ok, folder}
  end

  defp refresh_folder(
    %Folder{id: id, artist: %Artist{username: username}}
  ) do
    {:ok, token} = token_auth()

    url = "#{@base_url}/gallery/#{id}"
    params = %{
      mode: "newest",
      username: username,
      limit: 24,
      access_token: token,
      mature_content: true
    }

    {:ok, contents} = fetch_results(url, params)

    works = contents
    |> Enum.map(&get_work/1)
    |> Enum.filter(&(Map.get(&1, :file_url)))

    works |> Enum.with_index |> Enum.each(
      fn {%Work{
             id: work_id,
             title: title,
             page_url: page_url,
             file_url: file_url,
             thumb_url: thumb_url,
             thumb: thumb,
             thumb_type: thumb_type,
             file: file,
             file_type: file_type
          },
        index} ->
          Repo.insert(
            %Work{
              id: work_id,
              title: title,
              page_url: page_url,
              file_url: file_url,
              thumb_url: thumb_url,
              folder_id: id,
              thumb: thumb,
              thumb_type: thumb_type,
              file: file,
              file_type: file_type,
              index: index
            },
            on_conflict: :replace_all,
            conflict_target: :id)
      end)

    get_folder(id)
  end

  defp get_work(contents = %{"deviationid" => id}) do
    case Repo.get(Work, id) do
      %Work{} = work -> work
      nil -> refresh_work(contents)
    end
  end

  defp refresh_work(
    %{
      "deviationid" => id,
      "title" => title,
      "url" => page_url,
      "is_deleted" => false,
      "content" => %{"src" => file_url},
      "thumbs" => thumbs
    }) do

    thumb_url = case Enum.find(thumbs,
                      fn(%{"height" => h, "width" => w}) ->
                        w == 100 || h == 100
                      end) || List.first(thumbs) do
                  %{"src" => url} -> url
                  nil -> nil
                end
    {thumb, thumb_type} =
      case get(thumb_url, %{}) do
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: body,
           headers: headers
         }} ->
          {_, type} =
            Enum.find(headers, fn {name, _} -> name == "Content-Type" end)

          {body, type}
      end

    {file, file_type} =
      case get(file_url, %{}) do
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: body,
           headers: headers
         }} ->
          {_, type} =
            Enum.find(headers, fn {name, _} -> name == "Content-Type" end)

          {body, type}
      end

    %Work{
      id: id,
      title: title,
      page_url: page_url,
      file_url: file_url,
      thumb_url: thumb_url,
      thumb: thumb,
      thumb_type: thumb_type,
      file: file,
      file_type: file_type
    }
  end

  defp refresh_work(%{"deviationid" => id}) do
    %{id: id}
  end
end
