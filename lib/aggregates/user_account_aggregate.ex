defmodule SevenottersTester.UserAccountAggregate do
  use Seven.Otters.Aggregate, aggregate_field: :id

  defstruct id: nil, total: 0, goods: 5

  @withdraw_amount_command "WithdrawAmount"
  @amount_withdrawed_event "AmountWithdrawed"

  @deposit_amount_command "DepositAmount"
  @amount_deposited_event "AmountDeposited"

  @add_goods_command "AddGoods"
  @goods_added_event "GoodsAdded"

  @remove_goods_command "RemoveGoods"
  @goods_removed_event "GoodsRemoved"

  @moduledoc """
    Aggregate to test process.
    Responds to commands:
    - #{@withdraw_amount_command}
    - #{@deposit_amount_command}
    - #{@add_goods_command}
    - #{@remove_goods_command}
  """

  defp init_state, do: %__MODULE__{}

  @spec route(bitstring, any) :: {:routed, map, atom} | {:invalid, map}
  def route(@deposit_amount_command, params) do
    cmd = %{
      id: params[:id],
      amount: params[:amount]
    }

    command = Seven.Otters.Command.create(@deposit_amount_command, cmd)
    {:routed, command, __MODULE__}
  end

  def route(@withdraw_amount_command, params) do
    cmd = %{
      id: params[:id],
      amount: params[:amount]
    }

    command = Seven.Otters.Command.create(@withdraw_amount_command, cmd)
    {:routed, command, __MODULE__}
  end

  def route(@add_goods_command, params) do
    cmd = %{
      id: params[:id],
      goods: params[:goods]
    }

    command = Seven.Otters.Command.create(@add_goods_command, cmd)
    {:routed, command, __MODULE__}
  end

  def route(@remove_goods_command, params) do
    cmd = %{
      id: params[:id],
      goods: params[:goods]
    }

    command = Seven.Otters.Command.create(@remove_goods_command, cmd)
    {:routed, command, __MODULE__}
  end

  defp handle_command(%Seven.Otters.Command{type: @deposit_amount_command} = command, %{total: total}) do
    {:managed,
     [
       create_event(@amount_deposited_event, %{
         id: command.payload.id,
         amount: command.payload.amount,
         total: total + command.payload.amount
       })
     ]}
  end

  defp handle_command(%Seven.Otters.Command{type: @add_goods_command} = command, %{goods: goods}) do
    {:managed,
     [
       create_event(@goods_added_event, %{
         id: command.payload.id,
         goods: goods + command.payload.goods
       })
     ]}
  end

  defp handle_command(%Seven.Otters.Command{type: @withdraw_amount_command, payload: %{amount: amount}}, %{total: total})
       when total < amount do
    {:error, "no funds"}
  end

  defp handle_command(%Seven.Otters.Command{type: @withdraw_amount_command} = command, %{total: total}) do
    {:managed,
     [
       create_event(@amount_withdrawed_event, %{
         id: command.payload.id,
         amount: command.payload.amount,
         total: total - command.payload.amount
       })
     ]}
  end

  defp handle_command(%Seven.Otters.Command{type: @remove_goods_command, payload: %{goods: goods}}, %{goods: total_goods})
       when total_goods < goods do
    {:error, "no enought goods"}
  end

  defp handle_command(%Seven.Otters.Command{type: @remove_goods_command} = command, %{goods: goods}) do
    {:managed,
     [
       create_event(@goods_removed_event, %{
         id: command.payload.id,
         goods: goods - command.payload.goods
       })
     ]}
  end

  defp handle_event(%Seven.Otters.Event{type: @amount_deposited_event, payload: %{id: id, total: total}}, state) do
    %{state | id: id, total: total}
  end

  defp handle_event(%Seven.Otters.Event{type: @amount_withdrawed_event, payload: %{id: id, total: total}}, state) do
    %{state | id: id, total: total}
  end

  defp handle_event(%Seven.Otters.Event{type: @goods_added_event, payload: %{id: id, goods: goods}}, state) do
    %{state | id: id, goods: goods}
  end

  defp handle_event(%Seven.Otters.Event{type: @goods_removed_event, payload: %{id: id, goods: goods}}, state) do
    %{state | id: id, goods: goods}
  end
end
