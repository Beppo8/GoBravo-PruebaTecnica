defmodule WeatherApp.Favorites do
  import Ecto.Query, warn: false
  alias WeatherApp.Repo
  alias WeatherApp.Favorites.City

  def list_cities do
    Repo.all(City)
  end

  def get_city_by_name(name) do
    Repo.get_by(City, name: name)
  end

  def create_city(attrs \\ %{}) do
    %City{}
    |> City.changeset(attrs)
    |> Repo.insert()
  end
end
