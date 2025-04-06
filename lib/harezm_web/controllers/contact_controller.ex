defmodule HarezmWeb.ContactController do
  use HarezmWeb, :controller

  def show(conn, _params) do
    render(conn, :show)
  end
end
