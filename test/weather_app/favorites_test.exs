defmodule WeatherApp.FavoritesTest do
  use WeatherApp.DataCase

  alias WeatherApp.Favorites

  describe "cities" do
    alias WeatherApp.Favorites.City

    import WeatherApp.FavoritesFixtures

    @invalid_attrs %{name: nil}

    test "list_cities/0 returns all cities" do
      city = city_fixture()
      assert Favorites.list_cities() == [city]
    end

    test "get_city!/1 returns the city with given id" do
      city = city_fixture()
      assert Favorites.get_city!(city.id) == city
    end

    test "create_city/1 with valid data creates a city" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %City{} = city} = Favorites.create_city(valid_attrs)
      assert city.name == "some name"
    end

    test "create_city/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Favorites.create_city(@invalid_attrs)
    end

    test "update_city/2 with valid data updates the city" do
      city = city_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %City{} = city} = Favorites.update_city(city, update_attrs)
      assert city.name == "some updated name"
    end

    test "update_city/2 with invalid data returns error changeset" do
      city = city_fixture()
      assert {:error, %Ecto.Changeset{}} = Favorites.update_city(city, @invalid_attrs)
      assert city == Favorites.get_city!(city.id)
    end

    test "delete_city/1 deletes the city" do
      city = city_fixture()
      assert {:ok, %City{}} = Favorites.delete_city(city)
      assert_raise Ecto.NoResultsError, fn -> Favorites.get_city!(city.id) end
    end

    test "change_city/1 returns a city changeset" do
      city = city_fixture()
      assert %Ecto.Changeset{} = Favorites.change_city(city)
    end
  end
end
