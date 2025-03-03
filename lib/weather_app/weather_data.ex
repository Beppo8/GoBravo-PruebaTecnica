defmodule WeatherApp.WeatherData do
  use TypedStruct

  @moduledoc """
  Representa la información del clima actual.
  """

  typedstruct do
    field :temp, float(), required: true
    field :temp_min, float(), required: true
    field :temp_max, float(), required: true
    field :humidity, integer(), required: true
    field :description, String.t(), required: true
    field :icon, String.t(), required: true
  end
end
