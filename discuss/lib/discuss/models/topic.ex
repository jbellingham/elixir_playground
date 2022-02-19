defmodule Discuss.Models.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field :title, :string
  end

  @doc false
  def changeset(topic, attrs \\ %{}) do
    # \\ %{} is default value syntax. If nil is passed for attrs, default to an empty map
    topic
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
