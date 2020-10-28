defmodule SevenottersTester.SnapshotTesterProjection do
  @coins_added_event "CoinsAdded"

  use Seven.Otters.Projection,
    listener_of_events: [
      @coins_added_event
    ]

  defp init_state, do: %{events: 0}

  def special_id(), do: "a26e97cc-ffae-4949-bbf0-4df6f1752d81"

  @spec handle_event(Seven.Otters.Event.t(), List.t()) :: List.t()
  defp handle_event(%Seven.Otters.Event{type: @coins_added_event, payload: data}, state) do
    case data.number == special_id() do
      true -> state |> Map.put(data.number, data.sum) |> Map.put(:events, state.events + 1)
      false -> state
    end
  end

  defp pre_handle_query(:events, _params, _state), do: :ok

  defp handle_query(:events, nil, %{events: events}), do: events

  defp read_snapshot(correlation_id) do
    Seven.Data.Persistence.get_snapshot(correlation_id)
  end

  defp write_snapshot(correlation_id, snapshot) do
    Seven.Data.Persistence.upsert_snapshot(correlation_id, snapshot)
  end
end
