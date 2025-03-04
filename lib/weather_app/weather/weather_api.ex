defmodule Weather.WeatherAPI do
  @moduledoc """
  Cliente para consumir la API de OpenWeather.
  """

  # Funciones para obtener la configuración en tiempo de ejecución
  defp api_key, do: Application.fetch_env!(:weather_app, Weather.WeatherAPI)[:api_key]
  defp base_url, do: Application.fetch_env!(:weather_app, Weather.WeatherAPI)[:base_url]

  alias WeatherApp.WeatherData
  alias WeatherApp.ForecastEntry

  @spec get_current_weather(String.t()) :: {:ok, Map.t()} | {:error, String.t()}
  def get_current_weather(city) do
    url = "#{base_url()}/weather?q=#{URI.encode(city)}&units=metric&appid=#{api_key()}"

    case Finch.build(:get, url) |> Finch.request(MyFinch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        data = Jason.decode!(body)

        weather = %WeatherData{
          temp: data["main"]["temp"],
          temp_min: data["main"]["temp_min"],
          temp_max: data["main"]["temp_max"],
          humidity: data["main"]["humidity"],
          description:
            data["weather"] |> List.first() |> Map.get("description", "Sin descripción"),
          icon: data["weather"] |> List.first() |> Map.get("icon", "")
        }

        {:ok, Map.put(data, "weather_data", weather)}

      {:ok, %Finch.Response{status: status}} ->
        {:error, "Error al obtener clima. Código de estado: #{status}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec get_forecast(String.t()) :: {:ok, Map.t()} | {:error, String.t()}
  def get_forecast(city) do
    url = "#{base_url()}/forecast?q=#{URI.encode(city)}&units=metric&appid=#{api_key()}"

    case Finch.build(:get, url) |> Finch.request(MyFinch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %Finch.Response{status: status}} ->
        {:error, "Error al obtener pronóstico. Código de estado: #{status}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec get_forecast_by_coords(Float.t(), Float.t()) :: {:ok, Map.t()} | {:error, String.t()}
  def get_forecast_by_coords(lat, lon) do
    url = "#{base_url()}/forecast?lat=#{lat}&lon=#{lon}&units=metric&appid=#{api_key()}"

    case Finch.build(:get, url) |> Finch.request(MyFinch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %Finch.Response{status: status}} ->
        {:error, "Error al obtener forecast por coords. Código de estado: #{status}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec hourly_forecast(ForecastEntry.t()) :: List.t()
  def hourly_forecast(forecast) do
    forecast["list"]
    |> Enum.take(8)
    |> Enum.map(fn entry ->
      %ForecastEntry{
        dt: entry["dt"],
        dt_txt: entry["dt_txt"],
        temp: entry["main"]["temp"],
        temp_min: entry["main"]["temp_min"],
        temp_max: entry["main"]["temp_max"],
        description:
          entry["weather"] |> List.first() |> Map.get("description", "Sin descripción"),
        icon: entry["weather"] |> List.first() |> Map.get("icon", "")
      }
    end)
  end

  @spec daily_forecast(ForecastEntry.t()) :: List.t()
  def daily_forecast(forecast) do
    forecast["list"]
    |> Enum.group_by(fn entry ->
      DateTime.from_unix!(entry["dt"]) |> DateTime.to_date()
    end)
    |> Enum.map(fn {date, entries} ->
      temp_mins = Enum.map(entries, fn entry -> entry["main"]["temp_min"] end)
      temp_maxs = Enum.map(entries, fn entry -> entry["main"]["temp_max"] end)
      %{date: date, temp_min: Enum.min(temp_mins), temp_max: Enum.max(temp_maxs)}
    end)
    |> Enum.sort_by(fn %{date: date} -> date end)
    |> Enum.reject(fn %{date: date} -> date == Date.utc_today() end)
  end

  @spec search_city(String.t()) :: {:ok, Map.t()} | {:error, String.t()}
  def search_city(query) do
    limit = 5

    url =
      "http://api.openweathermap.org/geo/1.0/direct?q=#{URI.encode(query)}&limit=#{limit}&appid=#{api_key()}"

    case Finch.build(:get, url) |> Finch.request(MyFinch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        results = Jason.decode!(body)

        results
        |> Enum.map(fn result ->
          case get_current_weather_by_coords(result["lat"], result["lon"]) do
            {:ok, weather_data} ->
              Map.put(result, "weather_data", weather_data)

            _ ->
              result
          end
        end)

      {:ok, %Finch.Response{status: status}} ->
        IO.puts("Error en search_city: Código de estado #{status}")
        []

      {:error, reason} ->
        IO.puts("Error en search_city: #{inspect(reason)}")
        []
    end
  end

  @spec get_current_weather_by_coords(Float.t(), Float.t()) :: {:ok, Map.t()} | {:error, String.t()}
  def get_current_weather_by_coords(lat, lon) do
    url = "#{base_url()}/weather?lat=#{lat}&lon=#{lon}&units=metric&appid=#{api_key()}"

    case Finch.build(:get, url) |> Finch.request(MyFinch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %Finch.Response{status: status}} ->
        {:error, "Error al obtener clima por coords. Código de estado: #{status}"}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
