defmodule SevenottersTester.EmptyAggregate do
  use Seven.Otters.Aggregate, aggregate_field: :number

  defstruct number: nil

  defp init_state, do: %__MODULE__{}
end
