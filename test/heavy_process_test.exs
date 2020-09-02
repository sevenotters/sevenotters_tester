defmodule HeavyProcessTest do
  use ExUnit.Case

  @timeout 20_000
  @number_of_processes 1..2_000

  @tag timeout: :infinity
  describe "Stress test" do
    test "run multiple processes" do
      @number_of_processes
      |> Enum.map(fn _ -> Task.async(fn -> run_complete_process() end) end)
      |> Enum.map(fn t -> Task.await(t, @timeout) end)
    end
  end

  #
  # Privates
  #

  defp process_unloaded(_process_id, 0), do: :timeout

  defp process_unloaded(process_id, n) do
    Process.sleep(10)
    if get_buy_process(process_id), do: process_unloaded(process_id, n - 1), else: :ok
  end

  defp get_account(id) do
    SevenottersTester.UserAccountAggregate
    |> TestHelper.get_registered_item(id)
    |> SevenottersTester.UserAccountAggregate.state()
    |> assert()
    |> Map.get(:internal_state)
  end

  defp get_buy_process(id) do
    SevenottersTester.BuyGoods
    |> TestHelper.get_registered_item(id)
  end

  defp deposit(id, amount) do
    %Seven.CommandRequest{
      id: TestHelper.new_id(),
      command: "DepositAmount",
      sender: __MODULE__,
      params: %{id: id, amount: amount}
    }
    |> Seven.CommandBus.send_command_request()
  end

  defp buy_goods(request_id, process_id, account1_id, goods, account2_id) do
    %Seven.CommandRequest{
      id: request_id,
      command: "BuyGoods",
      sender: __MODULE__,
      params: %{id: process_id, from_id: account1_id, to_id: account2_id, goods: goods}
    }
    |> Seven.CommandBus.send_command_request()
  end

  def kill(pid, timeout \\ 2_000) do
    true = Process.alive?(pid)
    ref = Process.monitor(pid)
    Process.exit(pid, :kill)

    receive do
      {:DOWN, ^ref, :process, ^pid, _reason} ->
        refute Process.alive?(pid)
        pid
    after
      timeout -> :timeout
    end
  end

  def run_complete_process() do
    account1_id = TestHelper.new_number()
    deposit(account1_id, 100)

    account2_id = TestHelper.new_number()
    deposit(account2_id, 10)

    Seven.EventStore.EventStore.subscribe("GoodsBought", self())
    request_id = TestHelper.new_id()
    process_id = TestHelper.new_id()

    assert buy_goods(request_id, process_id, account1_id, 5, account2_id) == :managed

    assert_receive %Seven.Otters.Event{type: "GoodsBought", request_id: ^request_id, correlation_module: SevenottersTester.BuyGoods}, @timeout

    assert process_unloaded(process_id, 1000) == :ok

    account1 = get_account(account1_id)
    assert account1.total == 105
    assert account1.goods == 0

    account2 = get_account(account2_id)
    assert account2.total == 5
    assert account2.goods == 10
  end
end
