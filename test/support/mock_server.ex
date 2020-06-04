defmodule Aelia.MockServer do
  use Plug.Router

  plug Plug.Parsers,
    parsers: [:json],
    pass:  ["application/json"],
    json_decoder: Jason

  plug :match
  plug :dispatch

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
    end
  end

  get "/user/profile/:username" do
    case conn.params do
      %{
        "access_token" => @test_token,
        "mature_content" => "true",
        "username" => username
      } ->
        if String.starts_with? username, "featured" do
          id = :crypto.hash(:sha, username) |> Base.encode16()
          icon_url = "/view/user/icons/#{username}"
          profile_url = "/view/user/profile/#{username}"

          json(conn, %{
                "user" => %{"usericon" => icon_url, "userid" => id},
                "profile_url" => profile_url,
                "real_name" => String.capitalize(username)})
        else
          Plug.Conn.send_resp(conn, 404, "not found")
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
        if String.starts_with? username, "featured" do
          id = :crypto.hash(:sha, "#{username}folder") |> Base.encode16()

          json(conn, %{
                "has_more" => false,
                "next_offset" => "null",
                "results" => [%{"folderid" => id,
                                "name" => "Featured",
                                "parent" => nil}]})
        else
          Plug.Conn.send_resp(conn, 404, "not found")
        end
    end
  end

  defp json(conn, status \\ 200, body = %{}) do
    conn
    |> Plug.Conn.update_resp_header(
      "content-type", "application/json", &(&1 <> "; charset=utf-8"))
    |> Plug.Conn.send_resp(status, body |> Jason.encode!)
  end
end
