defmodule NomifyWeb.DocumentLive.FormComponent do
  use NomifyWeb, :live_component

  alias Nomify.Documents

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage document records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="document-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:published_on]} type="date" label="Published On" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Document</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{document: document} = assigns, socket) do
    changeset =
      if document do
        AshPhoenix.Form.for_update(document, :revise, as: "document")
      else
        AshPhoenix.Form.for_create(Documents.Document, :submit, as: "document")
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn -> to_form(changeset) end)}
  end

  @impl true
  def handle_event("validate", %{"document" => document_params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, document_params)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"document" => document_params}, socket) do
    save_document(socket, socket.assigns.action, document_params)
  end

  defp save_document(socket, :edit, document_params) do
    case Documents.revise_document(socket.assigns.document, document_params) do
      {:ok, document} ->
        notify_parent({:saved, document})

        {:noreply,
         socket
         |> put_flash(:info, "Document updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_document(socket, :new, document_params) do
    case Documents.submit_document(document_params) do
      {:ok, document} ->
        notify_parent({:saved, document})

        {:noreply,
         socket
         |> put_flash(:info, "Document created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
