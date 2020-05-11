defmodule AeliaWeb.WorkControllerTest do
  use AeliaWeb.ConnCase

  alias Aelia.DeviantArt

  @create_attrs %{file_url: "some file_url", folder_id: "some folder_id", id: "some id", page_url: "some page_url", thumb_url: "some thumb_url", title: "some title"}
  @update_attrs %{file_url: "some updated file_url", folder_id: "some updated folder_id", id: "some updated id", page_url: "some updated page_url", thumb_url: "some updated thumb_url", title: "some updated title"}
  @invalid_attrs %{file_url: nil, folder_id: nil, id: nil, page_url: nil, thumb_url: nil, title: nil}

  def fixture(:work) do
    {:ok, work} = DeviantArt.create_work(@create_attrs)
    work
  end

  describe "index" do
    test "lists all works", %{conn: conn} do
      conn = get(conn, Routes.work_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Works"
    end
  end

  describe "new work" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.work_path(conn, :new))
      assert html_response(conn, 200) =~ "New Work"
    end
  end

  describe "create work" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.work_path(conn, :create), work: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.work_path(conn, :show, id)

      conn = get(conn, Routes.work_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Work"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.work_path(conn, :create), work: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Work"
    end
  end

  describe "edit work" do
    setup [:create_work]

    test "renders form for editing chosen work", %{conn: conn, work: work} do
      conn = get(conn, Routes.work_path(conn, :edit, work))
      assert html_response(conn, 200) =~ "Edit Work"
    end
  end

  describe "update work" do
    setup [:create_work]

    test "redirects when data is valid", %{conn: conn, work: work} do
      conn = put(conn, Routes.work_path(conn, :update, work), work: @update_attrs)
      assert redirected_to(conn) == Routes.work_path(conn, :show, work)

      conn = get(conn, Routes.work_path(conn, :show, work))
      assert html_response(conn, 200) =~ "some updated file_url"
    end

    test "renders errors when data is invalid", %{conn: conn, work: work} do
      conn = put(conn, Routes.work_path(conn, :update, work), work: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Work"
    end
  end

  describe "delete work" do
    setup [:create_work]

    test "deletes chosen work", %{conn: conn, work: work} do
      conn = delete(conn, Routes.work_path(conn, :delete, work))
      assert redirected_to(conn) == Routes.work_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.work_path(conn, :show, work))
      end
    end
  end

  defp create_work(_) do
    work = fixture(:work)
    %{work: work}
  end
end
