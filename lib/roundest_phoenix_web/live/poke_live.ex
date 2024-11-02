defmodule RoundestPhoenixWeb.PokeLive do
  use Phoenix.LiveView,
    layout: {RoundestPhoenixWeb.Layouts, :app}

  import Ecto.Query
  alias RoundestPhoenix.Repo
  alias RoundestPhoenix.Pokemon

  def render(%{page: "loading"} = assigns) do
    ~H"""
    <div class="w-full grow flex flex-col items-center justify-center gap-8">
      <div class="md:grid grid-cols-2 gap-8">
        <div class="flex flex-col gap-4">
          <div class="w-48 h-48 bg-gray-200 animate-pulse"></div>
          <div class="text-center font-light text-neutral-500">Loading...</div>
        </div>

        <div class="flex flex-col gap-4">
          <div class="w-48 h-48 bg-gray-200 animate-pulse"></div>
          <div class="text-center font-light text-neutral-500">Loading...</div>
        </div>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="w-full grow flex flex-col items-center justify-center gap-8">
      <%!-- Hidden images to preload --%>
      <img
        src={"/pokemon/image/#{@nextFirstEntry.dex_id}"}
        alt={"#{@nextFirstEntry.name}"}
        class="w-0 h-0"
      />
      <img
        src={"/pokemon/image/#{@nextSecondEntry.dex_id}"}
        alt={"#{@nextSecondEntry.name}"}
        class="w-0 h-0"
      />
      <div class="md:grid grid-cols-2 gap-8">
        <div class="flex flex-col gap-4">
          <img
            src={"/pokemon/image/#{@firstEntry.dex_id}"}
            alt={"#{@firstEntry.name}"}
            class="w-48 h-48"
          />
          <div class="text-center font-light text-neutral-500">#<%= @firstEntry.dex_id %></div>
          <button
            class="hover:bg-gray-700 bg-blue-600 text-white px-4 py-2 rounded-md"
            phx-click="vote"
            phx-value-winner_id={@firstEntry.id}
            phx-value-loser_id={@secondEntry.id}
          >
            <%= @firstEntry.name %>
          </button>
        </div>

        <div class="flex flex-col gap-4">
          <img
            src={"/pokemon/image/#{@secondEntry.dex_id}"}
            alt={"#{@secondEntry.name}"}
            class="w-48 h-48"
          />
          <div class="text-center font-light text-neutral-500">#<%= @secondEntry.dex_id %></div>
          <button
            class="hover:bg-gray-700 bg-blue-600 text-white px-4 py-2 rounded-md"
            phx-click="vote"
            phx-value-winner_id={@secondEntry.id}
            phx-value-loser_id={@firstEntry.id}
          >
            <%= @secondEntry.name %>
          </button>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("vote", %{"winner_id" => winner_id, "loser_id" => loser_id}, socket) do
    case record_vote(socket, winner_id, loser_id) do
      {:ok, _} ->
        firstEntry = socket.assigns.nextFirstEntry
        secondEntry = socket.assigns.nextSecondEntry
        [nextFirstEntry, nextSecondEntry] = get_random_pair()

        {:noreply,
         socket
         |> assign(:firstEntry, firstEntry)
         |> assign(:secondEntry, secondEntry)
         |> assign(:nextFirstEntry, nextFirstEntry)
         |> assign(:nextSecondEntry, nextSecondEntry)}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to record vote")}
    end
  end

  # tragic: https://kobrakai.de/kolumne/liveview-double-mount
  def mount(params, session, socket) do
    [firstEntry, secondEntry] = get_random_pair()
    [nextFirstEntry, nextSecondEntry] = get_random_pair()

    # this is to avoid a double mount
    case connected?(socket) do
      true ->
        connected_mount(params, session, socket)

      false ->
        {:ok, assign(socket, page: "loading")}
    end

    {:ok,
     socket
     |> assign(:firstEntry, firstEntry)
     |> assign(:secondEntry, secondEntry)
     |> assign(:nextFirstEntry, nextFirstEntry)
     |> assign(:nextSecondEntry, nextSecondEntry)}
  end

  defp connected_mount(_params, _session, socket) do
    [firstEntry, secondEntry] = get_random_pair()

    {:ok,
     socket
     |> assign(:firstEntry, firstEntry)
     |> assign(:secondEntry, secondEntry)}
  end

  defp record_vote(socket, winner_id, loser_id) do
    firstEntry = socket.assigns.firstEntry
    secondEntry = socket.assigns.secondEntry

    winner =
      case firstEntry.id == winner_id do
        true -> secondEntry
        false -> firstEntry
      end

    loser =
      case firstEntry.id == loser_id do
        true -> secondEntry
        false -> firstEntry
      end

    IO.puts(winner.name)

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
