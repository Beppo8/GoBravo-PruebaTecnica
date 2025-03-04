defmodule WeatherApp.ForecastEntry do
  @derive {Jason.Encoder, only: [:dt, :dt_txt, :temp, :temp_min, :temp_max, :description, :icon]}
  use TypedStruct

  @moduledoc """
  Representa una entrada del forecast (por ejemplo, cada 3 horas).
  """

  typedstruct do
    field :dt, integer(), required: true
    field :dt_txt, String.t(), required: true
    field :temp, float(), required: true
    field :temp_min, float(), required: true
    field :temp_max, float(), required: true
    field :description, String.t(), required: true
    field :icon, String.t(), required: true
  end
end
