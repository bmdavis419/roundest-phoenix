defmodule RoundestPhoenixWeb.EntryController do
  use RoundestPhoenixWeb, :controller
  import Ecto.Query
  alias RoundestPhoenix.Repo
  alias RoundestPhoenix.Content.Entry

  def index(conn, _params) do
    query =
      from(e in Entry,
        order_by: fragment("RANDOM()"),
        limit: 2
      )

    entries = Repo.all(query)

    render(conn, :index, firstEntry: Enum.at(entries, 0), secondEntry: Enum.at(entries, 1))
  end

  def results(conn, _params) do
    entries = Repo.all(Entry)

    render(conn, :results, entries: entries)
  end

  def vote(conn, %{"winner_id" => winner_id, "loser_id" => loser_id}) do
    winner = Repo.get!(Entry, winner_id)
    loser = Repo.get!(Entry, loser_id)

    Repo.transaction(fn ->
      case winner |> Ecto.Changeset.change(%{up_vote: winner.up_vote + 1}) |> Repo.update() do
        {:ok, _winner} ->
          case loser
               |> Ecto.Changeset.change(%{down_vote: loser.down_vote + 1})
               |> Repo.update() do
            {:ok, _loser} -> :ok
            {:error, _} -> Repo.rollback(:error)
          end

        {:error, _} ->
          Repo.rollback(:error)
      end
    end)
    |> case do
      {:ok, _} ->
        conn |> redirect(to: ~p"/")

      {:error, _} ->
        conn
        |> put_flash(:error, "Failed to record")
        |> redirect(to: ~p"/")
    end
  end
end
