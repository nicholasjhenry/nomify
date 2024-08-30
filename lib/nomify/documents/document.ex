defmodule Nomify.Documents.Document do
  use Ash.Resource,
    domain: Nomify.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAdmin.Resource]

  postgres do
    table "documents"
    repo Nomify.Repo
  end

  actions do
    defaults [:read]

    create :submit do
      accept [:title, :published_on]
    end

    update :revise do
      accept [:title, :published_on]
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true
      filter expr(id == ^arg(:id))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
      public? true
    end

    attribute :published_on, :date do
      allow_nil? false
      public? true
      default &Date.utc_today/0
    end

    attribute :security_level, :atom do
      allow_nil? false
      constraints one_of: [:low, :medium, :high, :secret]
      public? true
      default :low
    end
  end
end
