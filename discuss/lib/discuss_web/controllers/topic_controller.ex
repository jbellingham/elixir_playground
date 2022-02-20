defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller
  alias Discuss.Models.Topic
  alias Discuss.Repo

  # Apply plug to specific actions in the controller
  plug DiscussWeb.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
  plug :check_topic_owner when action in [:update, :edit, :delete]

  def index(conn, _params) do
    topics = Repo.all(Topic)
    render conn, "index.html", topics: topics
  end

  def show(conn, %{"id" => topic_id}) do
    # get vs. get!
    # get will not throw an error if nothing was found, basically the same as .SingleOrDefault() in .NET
    # returns nil if not found
    # get! _will_ throw an error if nothing was found, basically the same as .Single() in .NET
    topic = Repo.get!(Topic, topic_id)
    render conn, "show.html", topic: topic
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"topic" => topic}) do
    # Sort of like console.log()
    IO.inspect(topic)
    changeset =
      # get user struct from session
      conn.assigns[:user]
      # pipe user in as first argument to build_assoc
      # build_assoc will return a changeset for a new Topic
      # with properties for the one-many or many-many relationship populated
      |> Ecto.build_assoc(:topics)
      # pipe the changeset returned from build_assoc into the first argument
      # of Topic.changeset. Previously for create we just had an empty Topic as
      # the basis of the changeset, e.g.
      # %Topic{}
      # Now we have an empty changeset, but with user_id filled out from build_assoc
      |> Topic.changeset(topic)

    case Repo.insert(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic created.")
        |> redirect(to: Routes.topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  def edit(conn, %{"id" => topic_id}) do
    topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(topic)
    render conn, "edit.html", changeset: changeset, topic: topic
  end

  def update(conn, %{"id" => topic_id, "topic" => topic}) do
    old_topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(old_topic, topic)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic updated.")
        |> redirect(to: Routes.topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset, topic: old_topic
    end
  end

  def delete(conn, %{"id" => topic_id}) do
    Repo.get!(Topic, topic_id)
    |> Repo.delete!

    conn
    |> put_flash(:info, "Topic deleted.")
    |> redirect(to: Routes.topic_path(conn, :index))
  end

  def check_topic_owner(conn, _params) do
    %{params: %{"id" => topic_id}} = conn
    if Repo.get(Topic, topic_id).user_id == conn.assigns[:user].id do
        conn
    else
        conn
        |> put_flash(:error, "You don't have permission to do that.")
        |> redirect(to: Routes.topic_path(conn, :index))
        |> halt()
    end
  end
end
