defmodule WeatherAppWeb.WeatherLiveTest do
  use WeatherAppWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  @moduletag :capture_log

  test "renders the search page", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/weather")
    assert html =~ "Consulta de Clima"
  end

  test "search event shows results", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/weather")
    render_submit(view, "search", %{"query" => "Paris"})
    assert render(view) =~ "Resultados de búsqueda"
  end

  test "add_favorite event updates the view", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/weather")
    city_data = %{
      "name" => "Paris",
      "country" => "FR",
      "state" => "Ile-de-France",
      "lat" => 48.8589,
      "lon" => 2.32,
      "weather_data" => %{
        "main" => %{"temp" => 11.89, "temp_min" => 10.66, "temp_max" => 12.26},
        "weather" => [
          %{"description" => "clear sky", "icon" => "01d"}
        ]
      }
    }
    json_data = Jason.encode!(city_data)
    render_click(view, "add_favorite", %{"data" => json_data})
    html = render(view)
    assert html =~ "Paris"
  end

  test "select_city event updates view with stored city data", %{conn: conn} do
    # Primero, se inserta una ciudad en favoritos
    city_attrs = %{
      "name" => "TestCity",
      "data" => %{
        "weather_data" => %{
          "main" => %{"temp" => 20.0, "temp_min" => 18.0, "temp_max" => 22.0},
          "weather" => [%{"description" => "sunny", "icon" => "01d"}]
        },
        "forecast" => %{
          "hourly" => [%{"dt_txt" => "2025-03-03 12:00:00", "temp" => 21.0}],
          "daily" => [%{"date" => "2025-03-04", "temp_min" => 17.0, "temp_max" => 23.0}]
        }
      }
    }
    {:ok, _city} = WeatherApp.Favorites.create_city(city_attrs)

    {:ok, view, _html} = live(conn, "/weather")
    render_click(view, "select_city", %{"city" => "TestCity"})
    html = render(view)
    assert html =~ "TestCity"
    assert html =~ "20.0"
    assert html =~ "2025-03-03 12:00:00"
    assert html =~ "2025-03-04"
  end

  test "select_city event fetches data when city is not in favorites", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/weather")
    render_click(view, "select_city", %{"city" => "NonExistentCity"})
    html = render(view)
    # Dado que en test no se simula la API para este caso, esperamos que no se muestre información
    refute html =~ "°C"
  end
end
