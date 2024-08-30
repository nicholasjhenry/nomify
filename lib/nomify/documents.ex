defmodule Nomify.Documents do
  use Ash.Domain, extensions: [AshAdmin.Domain]

  admin do
    show?(true)
  end

  resources do
    resource Nomify.Documents.Document do
      define :submit_document, action: :submit
      define :revise_document, action: :revise
      define :list_documents, action: :read
      define :get_document, args: [:id], action: :by_id
    end
  end
end
