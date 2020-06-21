defmodule SevenottersTester.TesterProjection do

  use Seven.Otters.Projection,
    listener_of_events: [
      "ValueAdded"
    ]

  defstruct total: 0

  defp init_state, do: 0

  @spec handle_event(Seven.Otters.Event.t(), List.t()) :: List.t()
  defp handle_event(%Seven.Otters.Event{type: "ValueAdded", payload: %{v1: %{value: value}}}, state) do
    state + value
  end
end
