defmodule WeatherAppWeb.WeatherLiveTest do
  use WeatherAppWeb.ConnCase
  import Phoenix.LiveViewTest

  test "renders the search page", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/weather")
    assert html =~ "Consulta de Clima"
  end

  test "search event shows results", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/weather")
    # Simula el envío del formulario de búsqueda
    render_submit(view, :search, %{"query" => "Rome"})
    # Se asume que al menos se renderiza la sección de "Resultados de búsqueda"
    assert render(view) =~ "Resultados de búsqueda"
  end

  test "add_favorite event updates the view", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/weather")
    # Se simula un JSON de datos obtenido en la búsqueda
    city_data = %{
      "name" => "Rome",
      "country" => "IT",
      "state" => "Lazio",
      "lat" => 41.8933,
      "lon" => 12.4829,
      "weather_data" => %{
        "main" => %{"temp" => 15.0, "temp_min" => 14.0, "temp_max" => 16.0},
        "weather" => [%{"description" => "clear sky", "icon" => "01d"}]
      }
    }
    json_data = Jason.encode!(city_data)
    # Se dispara el evento "add_favorite" con los datos en JSON
    render_click(view, :add_favorite, %{"data" => json_data})
    # Verifica que la sección de Favoritos se actualice mostrando "Rome"
    assert render(view) =~ "Rome"
  end
end
