defmodule Aelia.MockServer do
  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  @test_token "TEST_DEVIANTART_TOKEN"
  @client_id Application.fetch_env!(:aelia, :da_client_id)
  @client_secret Application.fetch_env!(:aelia, :da_client_secret)

  get "/auth" do
    case conn.params do
      %{
        "grant_type" => "client_credentials",
        "client_id" => @client_id,
        "client_secret" => @client_secret
      } ->
        json(conn, %{"status" => "success", "access_token" => @test_token})

      _ ->
        json(conn, 400, %{"status" => "bad request"})
    end
  end

  get "/user/profile/:username" do
    case conn.params do
      %{
        "access_token" => @test_token,
        "mature_content" => "true",
        "username" => username
      } ->
        if username |> String.starts_with?("missing:") do
          Plug.Conn.send_resp(conn, 404, "not found")
        else
          user_id = id(username)
          icon_url = "/view/user/icons/#{username}"
          profile_url = "/view/user/profile/#{username}"

          json(conn, %{
            "user" => %{"usericon" => icon_url, "userid" => user_id},
            "profile_url" => profile_url,
            "real_name" => String.capitalize(username)
          })
        end
    end
  end

  get "/gallery/folders" do
    case conn.params do
      %{
        "access_token" => @test_token,
        "mature_content" => "true",
        "username" => username,
        "offset" => "0"
      } ->
        featured_id = id("#{username}featured")
        featured = %{"folderid" => featured_id, "name" => "Featured", "parent" => nil}

        case username do
          "featured" ->
            json(conn, %{
              "has_more" => false,
              "next_offset" => "null",
              "results" => [featured]
            })

          "featured-multi" ->
            folders =
              [featured] ++
                Enum.map(
                  1..3,
                  fn index ->
                    %{
                      "folderid" => id("#{username}#{index}"),
                      "name" => "Folder #{index}",
                      "parent" => featured_id
                    }
                  end
                )

            json(conn, %{
              "has_more" => false,
              "next_offset" => "null",
              "results" => folders
            })

          "multi" ->
            parent_id = id("#{username}parent")
            parent = %{"folderid" => parent_id, "name" => "Parent", "parent" => featured_id}

            single = %{
              "folderid" => id("#{username}single"),
              "name" => "Single",
              "parent" => featured_id
            }

            folders =
              [featured, parent, single] ++
                Enum.map(
                  1..3,
                  fn index ->
                    %{
                      "folderid" => id("#{username}#{index}"),
                      "name" => "Folder #{index}",
                      "parent" => parent_id
                    }
                  end
                )

            json(conn, %{
              "has_more" => false,
              "next_offset" => "null",
              "results" => folders
            })

          username ->
            Plug.Conn.send_resp(conn, 404, "#{username} not found")
        end
    end
  end

  get "/gallery/:folder_id" do
    case conn.params do
      %{
        "folder_id" => folder_id = "empty-folder-id"
      } ->
        json(conn, %{
          "folderid" => folder_id,
          "has_more" => false,
          "next_offset" => "null",
          "results" => []
        })

      %{
        "folder_id" => folder_id = "work-folder-id"
      } ->
        json(conn, %{
          "folderid" => folder_id,
          "has_more" => false,
          "next_offset" => "null",
          "results" => [%{file_url: "first-work-file-url"}, %{file_url: "second-work-file-url"}]
        })
    end
  end

  defp id(string) do
    :crypto.hash(:sha, string) |> Base.encode16()
  end

  defp json(conn, status \\ 200, body = %{}) do
    conn
    |> Plug.Conn.update_resp_header(
      "content-type",
      "application/json",
      &(&1 <> "; charset=utf-8")
    )
    |> Plug.Conn.send_resp(status, body |> Jason.encode!())
  end
end
