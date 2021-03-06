defmodule Aelia.DeviantArt do
  alias Aelia.Repo
  alias Aelia.DeviantArt.{Artist, Folder, Work}
  alias Aelia.DeviantArt.HTTP

  import Ecto.Query, only: [from: 2]

  def base_url, do: Application.fetch_env!(:aelia, :da_base_url)

  def artist_info(username) do
    case Repo.get_by(Artist, username: username) do
      nil -> refresh_artist_info(username)
      %Artist{} = artist -> {:ok, preload_folders(artist)}
    end
  end

  def folder(username, index) do
    # TODO: Clean up!
    artist = Repo.get_by!(Artist, username: username)

    Repo.get_by!(Folder, artist_id: artist.id, index: index)
    |> Repo.preload(:artist)
    |> refresh_folder
  end

  defp preload_folders(%Artist{} = artist) do
    query = from f in Folder, where: is_nil(f.parent_id), order_by: f.index

    artist
    |> Repo.preload(folders: query)
    |> Repo.preload(folders: [children: from(f in Folder, order_by: f.index)])
  end

  defp refresh_artist_info(username) do
    {:ok, token} = HTTP.token_auth()

    url = "#{base_url()}/user/profile/#{username}"

    params = %{
      username: username,
      access_token: token,
      ext_collections: false,
      ext_galleries: false,
      mature_content: true
    }

    case HTTP.fetch(url, params) do
      {:ok,
       %{
         "user" => %{"usericon" => icon_url, "userid" => id},
         "profile_url" => profile_url,
         "real_name" => name
       }} ->
        case Repo.transaction(fn ->
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

               # TODO: Refactor this mess.
               case refresh_folders(token, id, username) do
                 {:ok, _} -> {:ok, preload_folders(artist)}
                 error -> error
               end
             end) do
          {:ok, inner} -> inner
          error -> error
        end

      {:error, message} ->
        case Regex.named_captures(~r/Bad Request: (?<json>.*)/, message) do
          %{"json" => json} ->
            {:error,
             Jason.decode!(json)
             |> Map.get("error_description")
             |> String.capitalize()}

          nil ->
            {:error, message}
        end
    end
  end

  defp refresh_folders(token, artist_id, username) do
    url = "#{base_url()}/gallery/folders"

    params = %{
      username: username,
      access_token: token,
      mature_content: true
    }

    case HTTP.fetch_results(url, params) do
      {:ok, folders} ->
        %{"folderid" => featured_id} = Enum.find(folders, &(Map.get(&1, "name") == "Featured"))

        folders
        |> Enum.with_index()
        |> Enum.each(fn {%{
                           "folderid" => id,
                           "name" => name,
                           "parent" => parent_id
                         }, index} ->
          parent_id =
            if parent_id == featured_id do
              nil
            else
              parent_id
            end

          Repo.insert(
            %Folder{id: id, name: name, artist_id: artist_id, parent_id: parent_id, index: index},
            on_conflict: :replace_all,
            conflict_target: :id
          )
        end)

        {:ok, folders}

      error ->
        error
    end
  end

  defp get_folder(id) do
    works_query = from w in Work, order_by: w.index

    folder =
      Repo.one(
        from f in Folder,
          where: f.id == ^id,
          preload: [works: ^works_query],
          preload: :artist
      )

    {:ok, folder}
  end

  defp refresh_folder(%Folder{id: id, artist: %Artist{username: username}}) do
    {:ok, token} = HTTP.token_auth()

    url = "#{base_url()}/gallery/#{id}"

    params = %{
      mode: "newest",
      username: username,
      limit: 24,
      access_token: token,
      mature_content: true
    }

    {:ok, contents} = HTTP.fetch_results(url, params)

    works =
      contents
      |> Enum.map(&get_work/1)
      |> Enum.filter(&Map.get(&1, :file_url))

    works
    |> Enum.with_index()
    |> Enum.each(fn {%Work{
                       id: work_id,
                       title: title,
                       page_url: page_url,
                       file_url: file_url,
                       thumb_url: thumb_url,
                       thumb: thumb,
                       thumb_ext: thumb_ext,
                       file: file,
                       file_ext: file_ext
                     }, index} ->
      Repo.insert(
        %Work{
          id: work_id,
          title: title,
          page_url: page_url,
          file_url: String.replace(file_url, ~r/[?]token=.*/, ""),
          thumb_url: String.replace(thumb_url, ~r/[?]token=.*/, ""),
          folder_id: id,
          thumb: thumb,
          thumb_ext: thumb_ext,
          file: file,
          file_ext: file_ext,
          index: index
        },
        on_conflict: :replace_all,
        conflict_target: :id
      )
    end)

    get_folder(id)
  end

  defp get_work(contents = %{"deviationid" => id}) do
    case Repo.get(Work, id) do
      %Work{} = work -> work
      nil -> refresh_work(contents)
    end
  end

  defp refresh_work(%{
         "deviationid" => id,
         "title" => title,
         "url" => page_url,
         "is_deleted" => false,
         "content" => %{"src" => file_url},
         "thumbs" => thumbs
       }) do
    thumb_url =
      case Enum.find(
             thumbs,
             fn %{"height" => h, "width" => w} ->
               w == 100 || h == 100
             end
           ) || List.first(thumbs) do
        %{"src" => url} -> url
        nil -> nil
      end

    {thumb, thumb_ext} =
      case HTTP.get(thumb_url, %{}) do
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: body,
           headers: headers
         }} ->
          {_, type} = Enum.find(headers, fn {name, _} -> name == "Content-Type" end)

          {body, HTTP.type_to_ext(type)}
      end

    {file, file_ext} =
      case HTTP.get(file_url, %{}) do
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: body,
           headers: headers
         }} ->
          {_, type} = Enum.find(headers, fn {name, _} -> name == "Content-Type" end)

          {body, HTTP.type_to_ext(type)}
      end

    %Work{
      id: id,
      title: title,
      page_url: page_url,
      file_url: file_url,
      thumb_url: thumb_url,
      thumb: thumb,
      thumb_ext: thumb_ext,
      file: file,
      file_ext: file_ext
    }
  end

  defp refresh_work(%{"deviationid" => id}) do
    %{id: id}
  end
end
