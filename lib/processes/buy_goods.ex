defmodule SevenottersTester.BuyGoods do
  use Seven.Otters.Process, process_field: :id, listener_of_events: ["AmountWithdrawed", "GoodsAdded"]

  defstruct id: nil,
            from_id: nil,
            to_id: nil,
            goods: nil,
            status: :not_started

  @buy_goods_command "BuyGoods"
  @buy_goods_process_started_event "BuyGoodsStarted"
  @buy_goods_process_error_event "BuyGoodsErrorOccurred"

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

  defp handle_command(%Seven.Otters.Command{type: @buy_goods_command} = command, process_id, state) do
    payload = command.payload
    state = %{state | id: payload.id, from_id: payload.from_id, to_id: payload.to_id, goods: payload.goods}

    res =
      %Seven.CommandRequest{
        id: command.request_id,
        process_id: process_id,
        command: "WithdrawAmount",
        params: %{id: payload.to_id, amount: payload.goods}
      }
      |> send_command(state)

    case res do
      :managed ->
        events = [create_event(@buy_goods_process_started_event, %{process_id: payload.id})]
        {:continue, events, %{state | status: :started}}

      {:error, reason} ->
        events = [create_event(@buy_goods_process_error_event, %{process_id: payload.id, reason: reason})]
        {:error, reason, events, %{state | status: :error}}
    end
  end

  defp handle_event(%Seven.Otters.Event{type: "AmountWithdrawed", payload: payload} = event, state) do
    if payload.id == state.to_id do
      res =
        %Seven.CommandRequest{
          id: event.request_id,
          process_id: event.process_id,
          command: "RemoveGoods",
          params: %{id: state.from_id, goods: state.goods}
        }
        |> send_command(state)

      case res do
        :managed ->
          %Seven.CommandRequest{
            id: event.request_id,
            process_id: event.process_id,
            command: "AddGoods",
            params: %{id: state.to_id, goods: state.goods}
          }
          |> send_command(state)

          {:continue, [], state}

        {:error, reason} ->
          # rollback modified aggregate
          %Seven.CommandRequest{
            id: event.request_id,
            process_id: event.process_id,
            command: "DepositAmount",
            params: %{id: state.to_id, amount: state.goods}
          }
          |> send_command(state)

          events = [create_event(@buy_goods_process_error_event, %{process_id: payload.id, reason: reason})]
          {:stop, events, %{state | status: :error}}
      end
    end
  end

  defp handle_event(%Seven.Otters.Event{type: "GoodsAdded", payload: payload} = event, state) do
    if payload.id == state.to_id do
      %Seven.CommandRequest{
        id: event.request_id,
        process_id: event.process_id,
        command: "DepositAmount",
        params: %{id: state.from_id, amount: state.goods}
      }
      |> send_command(state)

      events = [create_event("GoodsBought", %{process_id: event.process_id})]
      {:stop, events, %{state | status: :finished}}
    else
      {:continue, [], state}
    end
  end
end
