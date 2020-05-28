defmodule AeliaWeb.PageControllerTest do
  use AeliaWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Aelia"
  end
end
