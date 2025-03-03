defmodule WeatherAppWeb.WeatherLive do
  use WeatherAppWeb, :live_view

  alias Weather.WeatherAPI
  alias WeatherApp.Favorites
  alias WeatherApp.Favorites.City

  @impl true
  def mount(_params, _session, socket) do
    favorites = Favorites.list_cities()
    socket =
      socket
      |> assign(:query, "")
      |> assign(:results, [])
      |> assign(:favorites, favorites)
      |> assign(:weather, nil)
      |> assign(:hourly_forecast, [])
      |> assign(:daily_forecast, [])
    {:ok, socket}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    results = WeatherAPI.search_city(query)
    {:noreply, assign(socket, query: query, results: results)}
  end

  @impl true
  def handle_event("add_favorite", %{"data" => data_json}, socket) do
    IO.puts("Evento add_favorite recibido")
    data = Jason.decode!(data_json)
    lat = data["lat"]
    lon = data["lon"]

    with {:ok, forecast} <- WeatherAPI.get_forecast_by_coords(lat, lon) do
      hourly = WeatherAPI.hourly_forecast(forecast)
      daily  = WeatherAPI.daily_forecast(forecast)
      # Agregar el forecast a la estructura data
      data = Map.put(data, "forecast", %{
        "hourly" => hourly,
        "daily"  => daily
      })

      city_attrs = %{"name" => data["name"], "data" => data}

      case Favorites.create_city(city_attrs) do
        {:ok, _city} ->
          favorites = Favorites.list_cities()
          {:noreply, assign(socket, favorites: favorites, weather: data["weather_data"], hourly_forecast: hourly, daily_forecast: daily)}
        {:error, _reason} ->
          {:noreply, socket}
      end
    else
      error ->
        IO.inspect(error, label: "Error al obtener forecast en add_favorite")
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("select_city", %{"city" => city_name}, socket) do
    IO.puts("Evento select_city recibido para: #{city_name}")
    case Favorites.get_city_by_name(city_name) do
      nil ->
        with {:ok, weather} <- WeatherAPI.get_current_weather(city_name),
             {:ok, forecast} <- WeatherAPI.get_forecast(city_name) do
          hourly = WeatherAPI.hourly_forecast(forecast)
          daily  = WeatherAPI.daily_forecast(forecast)
          {:noreply, assign(socket, weather: weather, hourly_forecast: hourly, daily_forecast: daily)}
        else
          error ->
            IO.inspect(error, label: "Error en select_city (no favorite)")
            {:noreply, socket}
        end
      city ->
        weather = city.data["weather_data"]
        forecast = city.data["forecast"] || %{}
        hourly = forecast["hourly"] || []
        daily  = forecast["daily"]  || []
        {:noreply, assign(socket, weather: weather, hourly_forecast: hourly, daily_forecast: daily)}
    end
  end
end
