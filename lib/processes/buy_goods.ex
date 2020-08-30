defmodule SevenottersTester.BuyGoods do
  use Seven.Otters.Process, process_field: :id

  defstruct id: nil

  @buy_goods_command "BuyGoods"
  @buy_goods_process_started_event "BuyGoodsStarted"

  @moduledoc """
    Process to test process entity.
    Responds to commands:
    - #{@buy_goods_command}
  """

  defp init_state, do: %__MODULE__{}

  @spec route(String.t(), any) :: {:routed, Map.y(), atom} | {:invalid, Map.t()}
  def route(@buy_goods_command, params) do
    cmd = %{
      id: params[:id],
      from_id: params[:from_id],
      to_id: params[:to_id],
      goods: params[:goods]
    }

    command = Seven.Otters.Command.create(@buy_goods_command, cmd)
    {:routed, command, __MODULE__}
  end

  defp handle_command(%Seven.Otters.Command{type: @buy_goods_command} = command, state) do
    payload = command.payload
    state = %{state | id: payload.id}

    %Seven.CommandRequest{
      command: "WithdrawAmount",
      params: %{id: payload.to_id, amount: payload.goods}
    }
    |> send_command(state)

    events = [create_event(@buy_goods_process_started_event, %{process_id: payload.id})]

    {:continue, events, state}
  end
end
