defmodule SevenottersTester.TesterAggregate do
  use Seven.Otters.Aggregate, aggregate_field: :id

  defstruct id: nil, name: ""

  defp init_state, do: %__MODULE__{}

  defp handle_event(%Seven.Otters.Event{type: "NameChanged", payload: %{v1: %{new_name: new_name}}}, state) do
    %{state | name: new_name}
  end
end
