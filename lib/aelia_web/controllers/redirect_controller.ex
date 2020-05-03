defmodule AeliaWeb.RedirectController do
  use AeliaWeb, :controller
  @send_to "/"

  def to_aelia(conn, _params) do
    redirect(conn, to: "/aelia")
  end
end
