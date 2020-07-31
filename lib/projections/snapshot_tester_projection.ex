defmodule SevenottersTester.SnapshotTesterProjection do

  @coins_added_event "CoinsAdded"

  use Seven.Otters.Projection,
    listener_of_events: [
      @coins_added_event
    ]

  defp init_state, do: %{events: 0}

  def special_id(), do: "5f2416a66e9552a8968ec971"

  @spec handle_event(Seven.Otters.Event.t(), List.t()) :: List.t()
  defp handle_event(%Seven.Otters.Event{type: @coins_added_event, payload: data}, state) do
    case data.number == special_id() do
      true -> state |> Map.put(data.number, data.sum) |> Map.put(:events, state.events + 1)
      false -> state
    end
  end

  defp pre_handle_query(:events, _params, _state), do: :ok

  defp handle_query(:events, nil, %{events: events}), do: events
end
