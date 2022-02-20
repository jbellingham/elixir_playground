defmodule Discuss.Models.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :provider, :string
    field :token, :string

    # Modeling a one-many relationship
    has_many :topics, Discuss.Models.Topic
    has_many :comments, Discuss.Models.Comment

    timestamps()
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    # \\ %{} is default value syntax. If nil is passed for attrs, default to an empty map
    user
    |> cast(attrs, [:email, :provider, :token])
    |> validate_required([:email, :provider, :token])
  end
end
