defmodule Aelia.MockServer do
  use Plug.Router

  plug Plug.Parsers,
    parsers: [:json],
    pass:  ["text/*"],
    json_decoder: Jason

  plug :match
  plug :dispatch

  @test_token "TEST_DEVIANTART_TOKEN"
  @client_id System.get_env("CLIENT_ID")
  @client_secret System.get_env("CLIENT_SECRET")

  get "/auth" do
    case conn.params do
      %{"grant_type" => "client_credentials",
        "client_id" => nil,
        "client_secret" => nil} ->
        json(conn, 400, %{"status" => "failure", "message" => "nil token"})
      %{"grant_type" => "client_credentials",
        "client_id" => @client_id,
        "client_secret" => @client_secret} ->
        json(conn, %{"status" => "success", "access_token" => @test_token})
    end
  end

  def json(conn, status \\ 200, body = %{}) do
      Plug.Conn.send_resp(conn, status, body |> Jason.encode!)
  end
end
