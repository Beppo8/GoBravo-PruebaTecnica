defmodule Weather.WeatherAPITest do
  use ExUnit.Case, async: true

  alias Weather.WeatherAPI
  alias WeatherApp.WeatherData

  setup do
    bypass = Bypass.open()

    # Se guarda la configuración original y se sobreescribe la base_url en tiempo de ejecución.
    original_config = Application.get_env(:weather_app, Weather.WeatherAPI)
    Application.put_env(:weather_app, Weather.WeatherAPI, Keyword.put(original_config, :base_url, "http://localhost:#{bypass.port}"))

    on_exit(fn ->
      Application.put_env(:weather_app, Weather.WeatherAPI, original_config)
    end)

    {:ok, bypass: bypass}
  end

  test "get_current_weather returns weather data as WeatherData struct", %{bypass: bypass} do
    response_body = ~s({
      "main": {
        "temp": 15.0,
        "temp_min": 14.0,
        "temp_max": 16.0,
        "humidity": 80
      },
      "weather": [{
         "description": "clear sky",
         "icon": "01d"
      }],
      "name": "TestCity"
    })

    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, response_body)
    end)

    {:ok, result} = WeatherAPI.get_current_weather("TestCity")
    assert result["name"] == "TestCity"

    expected = %WeatherData{
      temp: 15.0,
      temp_min: 14.0,
      temp_max: 16.0,
      humidity: 80,
      description: "clear sky",
      icon: "01d"
    }
    assert expected == result["weather_data"]
  end

  test "get_current_weather_by_coords returns weather data", %{bypass: bypass} do
    response_body = ~s({
      "main": {
        "temp": 20.0,
        "temp_min": 18.0,
        "temp_max": 22.0,
        "humidity": 70
      },
      "weather": [{
         "description": "partly cloudy",
         "icon": "02d"
      }],
      "name": "CoordCity"
    })

    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, response_body)
    end)

    {:ok, result} = WeatherAPI.get_current_weather_by_coords(10.0, 20.0)
    assert result["name"] == "CoordCity"
  end

  test "get_forecast returns forecast data", %{bypass: bypass} do
    forecast_entries =
      Enum.map(1..5, fn i ->
        %{
          "dt" => 1600000000 + i * 10800,
          "dt_txt" => "2020-09-13 #{i}:00:00",
          "main" => %{
            "temp" => 10.0 + i,
            "temp_min" => 9.0 + i,
            "temp_max" => 11.0 + i
          },
          "weather" => [
            %{"description" => "rain", "icon" => "10d"}
          ]
        }
      end)

    response_body = Jason.encode!(%{"list" => forecast_entries})
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, response_body)
    end)

    {:ok, forecast} = WeatherAPI.get_forecast("TestCity")
    assert is_list(forecast["list"])
  end

  test "hourly_forecast returns first 8 entries as ForecastEntry structs", %{bypass: bypass} do
    forecast_entries =
      Enum.map(1..10, fn i ->
        %{
          "dt" => 1600000000 + i * 10800,
          "dt_txt" => "2020-09-13 #{i}:00:00",
          "main" => %{
            "temp" => 10.0 + i,
            "temp_min" => 9.0 + i,
            "temp_max" => 11.0 + i
          },
          "weather" => [
            %{"description" => "rain", "icon" => "10d"}
          ]
        }
      end)
    response_body = Jason.encode!(%{"list" => forecast_entries})
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, response_body)
    end)

    {:ok, forecast} = WeatherAPI.get_forecast("TestCity")
    hourly = WeatherAPI.hourly_forecast(forecast)
    assert length(hourly) == 8
    first_entry = hd(hourly)
    # Para i = 1, se espera que temp = 11.0
    assert first_entry.temp == 11.0
  end

  test "daily_forecast groups entries by day", %{bypass: bypass} do
    base_timestamp = 1600000000
    entries_day1 = Enum.map(1..4, fn _ ->
      %{"dt" => base_timestamp, "main" => %{"temp_min" => 10.0, "temp_max" => 15.0}}
    end)
    entries_day2 = Enum.map(1..4, fn _ ->
      %{"dt" => base_timestamp + 86400, "main" => %{"temp_min" => 8.0, "temp_max" => 13.0}}
    end)
    forecast_list = entries_day1 ++ entries_day2
    response_body = Jason.encode!(%{"list" => forecast_list})
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, response_body)
    end)

    {:ok, forecast} = WeatherAPI.get_forecast("TestCity")
    daily = WeatherAPI.daily_forecast(forecast)
    assert length(daily) >= 1
  end
end
