defmodule RoundestPhoenixWeb.PokemonController do
  use RoundestPhoenixWeb, :controller

  @cache_control_header "public, max-age=86400"
  @cache_ttl :timer.hours(24)

  def show_results(conn, _params) do
    render(conn, :results)
  end

  def show_image(conn, %{"dex_id" => dex_id}) do
    image_url =
      "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/#{dex_id}.png"

    case get_cached_image(image_url) do
      {:ok, image_binary} ->
        conn
        |> put_resp_header("cache-control", @cache_control_header)
        |> put_resp_content_type("image/png")
        |> send_resp(200, image_binary)

      {:error, _reason} ->
        conn
        |> put_status(404)
        |> text("Pokemon image not found")
    end
  end

  defp get_cached_image(url) do
    case Cachex.get(:pokemon_cache, url) do
      {:ok, nil} ->
        # Cache miss - fetch and cache the image
        case HTTPoison.get(url) do
          {:ok, %{status_code: 200, body: image_binary}} ->
            # Store in cache with TTL
            Cachex.put(:pokemon_cache, url, image_binary, ttl: @cache_ttl)
            {:ok, image_binary}

          _error ->
            {:error, :fetch_failed}
        end

      {:ok, image_binary} ->
        # Cache hit
        {:ok, image_binary}

      {:error, _reason} ->
        {:error, :cache_error}
    end
  end
end
