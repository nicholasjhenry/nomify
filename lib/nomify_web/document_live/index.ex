defmodule NomifyWeb.DocumentLive.Index do
  use NomifyWeb, :live_view

  alias Nomify.Documents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :documents, Documents.list_documents!())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    document = Documents.get_document!(id)

    socket |> assign(:page_title, "Edit Document") |> assign(:document, document) |> dbg
  end

  defp apply_action(socket, :new, _params) do
    document = nil

    socket
    |> assign(:page_title, "New Document")
    |> assign(:document, document)
  end

  defp apply_action(socket, :index, _params) do
    document = nil

    socket
    |> assign(:page_title, "Listing Documents")
    |> assign(:document, document)
  end

  @impl true
  def handle_info({NomifyWeb.DocumentLive.FormComponent, {:saved, document}}, socket) do
    {:noreply, stream_insert(socket, :documents, document)}
  end
end
