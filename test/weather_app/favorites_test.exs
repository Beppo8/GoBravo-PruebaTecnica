defmodule WeatherApp.FavoritesTest do
  use WeatherApp.DataCase, async: true

  alias WeatherApp.Favorites
  alias WeatherApp.Favorites.City

  @valid_attrs %{
    "name" => "TestCity",
    "data" => %{
      "weather_data" => %{"main" => %{"temp" => 20.0, "temp_min" => 18.0, "temp_max" => 22.0}, "weather" => [%{"description" => "sunny", "icon" => "01d"}]},
      "forecast" => %{"hourly" => [%{"dt_txt" => "2025-03-03 12:00:00", "temp" => 21.0}], "daily" => [%{"date" => "2025-03-04", "temp_min" => 17.0, "temp_max" => 23.0}]}
    }
  }
  @invalid_attrs %{"name" => nil}

  describe "Favorites context" do
    test "list_cities/0 returns all cities" do
      {:ok, city} = Favorites.create_city(@valid_attrs)
      cities = Favorites.list_cities()
      assert city in cities
    end

    test "get_city_by_name/1 returns the city when it exists" do
      {:ok, city} = Favorites.create_city(@valid_attrs)
      fetched = Favorites.get_city_by_name("TestCity")
      assert fetched.id == city.id
    end

    test "create_city/1 with valid data creates a city" do
      assert {:ok, %City{} = city} = Favorites.create_city(@valid_attrs)
      assert city.name == "TestCity"
    end

    test "create_city/1 with invalid data returns error changeset" do
      assert {:error, changeset} = Favorites.create_city(@invalid_attrs)
      refute changeset.valid?
    end
  end
end
