defmodule SevenottersTester.EmptyProjection do

  use Seven.Otters.Projection,
    listener_of_events: []

  defstruct data: nil

  defp init_state, do: []
end
