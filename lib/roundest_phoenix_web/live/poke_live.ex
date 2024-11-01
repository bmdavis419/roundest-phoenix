defmodule RoundestPhoenixWeb.PokeLive do
  use Phoenix.LiveView,
    layout: {RoundestPhoenixWeb.Layouts, :app}

  import Ecto.Query
  alias RoundestPhoenix.Repo
  alias RoundestPhoenix.Pokemon

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
          <img src={"/pokemon/image/#{@firstEntry.dex_id}"} alt={"Pokemon #{@firstEntry.dex_id}"} />
        </button>
        <button
          class="hover:bg-gray-700"
          phx-click="vote"
          phx-value-winner_id={@secondEntry.id}
          phx-value-loser_id={@firstEntry.id}
        >
          <img src={"/pokemon/image/#{@secondEntry.dex_id}"} alt={"Pokemon #{@secondEntry.dex_id}"} />
        </button>
      </div>
    </div>
    """
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

  def mount(_params, _session, socket) do
    [firstEntry, secondEntry] = get_random_pair()

    {:ok,
     socket
     |> assign(:firstEntry, firstEntry)
     |> assign(:secondEntry, secondEntry)}
  end

  defp record_vote(winner_id, loser_id) do
    winner = Repo.get!(Pokemon, winner_id)
    loser = Repo.get!(Pokemon, loser_id)

    Repo.transaction(fn ->
      case winner |> Ecto.Changeset.change(%{up_votes: winner.up_votes + 1}) |> Repo.update() do
        {:ok, _winner} ->
          case loser
               |> Ecto.Changeset.change(%{down_votes: loser.down_votes + 1})
               |> Repo.update() do
            {:ok, _loser} -> :ok
            {:error, _} -> Repo.rollback(:error)
          end

        {:error, _} ->
          Repo.rollback(:error)
      end
    end)
  end

  defp get_random_pair do
    query =
      from(e in Pokemon,
        order_by: fragment("RANDOM()"),
        limit: 2
      )

    Repo.all(query)
  end
end
