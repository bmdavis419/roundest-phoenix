defmodule RoundestPhoenixWeb.VoteLive do
  use Phoenix.LiveView,
    layout: {RoundestPhoenixWeb.Layouts, :app}

  import Ecto.Query
  alias RoundestPhoenix.Repo
  alias RoundestPhoenix.Content.Entry

  def render(assigns) do
    ~H"""
    <div class="w-full grow flex flex-col items-center justify-center gap-8">
      <div class="md:grid grid-cols-2">
        <button
          class="hover:bg-gray-700"
          phx-click="vote"
          phx-value-winner_id={@firstEntry.id}
          phx-value-loser_id={@secondEntry.id}
        >
          <img src={@firstEntry.url} alt="first image" />
        </button>
        <button
          class="hover:bg-gray-700"
          phx-click="vote"
          phx-value-winner_id={@secondEntry.id}
          phx-value-loser_id={@firstEntry.id}
        >
          <img src={@secondEntry.url} alt="first image" />
        </button>
      </div>
      <div>
        <button phx-click="get_new_set" class="bg-black text-white text-lg px-4 py-2 rounded-md">
          UPDATE THE PICS
        </button>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    [firstEntry, secondEntry] = get_random_pair()

    {:ok,
     socket
     |> assign(:firstEntry, firstEntry)
     |> assign(:secondEntry, secondEntry)}
  end

  def handle_event("get_new_set", _value, socket) do
    [firstEntry, secondEntry] = get_random_pair()

    {:noreply,
     socket
     |> assign(:firstEntry, firstEntry)
     |> assign(:secondEntry, secondEntry)}
  end

  def handle_event("vote", %{"winner_id" => winner_id, "loser_id" => loser_id}, socket) do
    case record_vote(winner_id, loser_id) do
      {:ok, _} ->
        [firstEntry, secondEntry] = get_random_pair()

        {:noreply,
         socket
         |> assign(:firstEntry, firstEntry)
         |> assign(:secondEntry, secondEntry)}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to record vote")}
    end
  end

  defp get_random_pair do
    query =
      from(e in Entry,
        order_by: fragment("RANDOM()"),
        limit: 2
      )

    Repo.all(query)
  end

  defp record_vote(winner_id, loser_id) do
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
  end
end
