defmodule SevenottersTester.SnapshottedAggregate do
  use Seven.Otters.Aggregate, aggregate_field: :number

  defstruct number: nil, sum: 0

  @add_coins_command "AddCoins"
  @coins_added_event "CoinsAdded"
  @wake_up_command "WakeUp"

  @moduledoc """
    Aggregate to test command validation.
    Responds to commands:
    - #{@add_coins_command}
  """

  defp init_state, do: %__MODULE__{}

  @spec route(bitstring, any) :: {:routed, map, atom} | {:invalid, map}
  def route(@add_coins_command, params) do
    cmd = %{
      number: params[:number],
      coins: params[:coins]
    }

    command = Seven.Otters.Command.create(@add_coins_command, cmd)
    {:routed, command, __MODULE__}
  end

  def route(@wake_up_command, params) do
    cmd = %{
      number: params[:number]
    }

    command = Seven.Otters.Command.create(@wake_up_command, cmd)
    {:routed, command, __MODULE__}
  end

  defp handle_command(%Seven.Otters.Command{type: @add_coins_command} = command, %{sum: sum}) do
    {:managed,
     [
       create_event(@coins_added_event, %{
         number: command.payload.number,
         coins: command.payload.coins,
         sum: sum + command.payload.coins
       })
     ]}
  end

  defp handle_command(%Seven.Otters.Command{type: @wake_up_command}, _state) do
    {:managed, []}
  end

  defp handle_event(%Seven.Otters.Event{type: @coins_added_event, payload: %{number: number, sum: sum}}, state) do
    %{state | number: number, sum: sum}
  end

  defp read_snapshot(correlation_id) do
    Seven.Data.Persistence.get_snapshot(correlation_id)
  end

  defp write_snapshot(correlation_id, snapshot) do
    Seven.Data.Persistence.upsert_snapshot(correlation_id, snapshot)
  end
end
