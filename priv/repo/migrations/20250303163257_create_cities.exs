defmodule WeatherApp.Repo.Migrations.CreateCities do
  use Ecto.Migration

  def change do
    create table(:cities) do
      add :name, :string
      add :data, :map

      timestamps(type: :utc_datetime)
    end
  end
end
