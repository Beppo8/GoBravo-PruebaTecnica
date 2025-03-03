defmodule WeatherApp.FavoritesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WeatherApp.Favorites` context.
  """

  @doc """
  Generate a city.
  """
  def city_fixture(attrs \\ %{}) do
    {:ok, city} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> WeatherApp.Favorites.create_city()

    city
  end
end
