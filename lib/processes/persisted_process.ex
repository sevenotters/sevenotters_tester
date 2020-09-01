defmodule SevenottersTester.PersistedProcess do
  use Seven.Otters.Process, process_field: :id, listener_of_events: ["TouchPersistedProcess"]

  defstruct [
    id: nil,
    status: :not_started
  ]

  @start_persisted_process_command "StartPersistedProcess"

  @moduledoc """
    Process to test process entity persistence.
    Responds to commands:
    - #{@start_persisted_process_command}
  """

  defp init_state, do: %__MODULE__{}

  @spec route(String.t(), any) :: {:routed, Map.y(), atom} | {:invalid, Map.t()}
  def route(@start_persisted_process_command, params) do
    cmd = %{id: params[:id]}

    command = Seven.Otters.Command.create(@start_persisted_process_command, cmd)
    {:routed, command, __MODULE__}
  end

  defp handle_command(%Seven.Otters.Command{type: @start_persisted_process_command} = command, _process_id, state) do
    {:continue, [], %{state | id: command.payload.id, status: :started}}
  end

  @spec handle_event(Seven.Otters.Event, __MODULE__) :: map
  defp handle_event(%Seven.Otters.Event{type: "TouchPersistedProcess"}, state) do
    {:continue, [], %{state | status: :touched}}
  end
end
