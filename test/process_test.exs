defmodule ProcessTest do
  use ExUnit.Case

  describe "User account tester" do
    test "deposit and withdraw" do
      account1_id = TestHelper.new_number()
      assert deposit(account1_id, 100) == :managed

      account2_id = TestHelper.new_number()
      assert deposit(account2_id, 10) == :managed

      assert get_account(account1_id).total == 100
      assert get_account(account2_id).total == 10

      assert withdraw(account1_id, 91) == :managed
      assert get_account(account1_id).total == 9

      assert withdraw(account2_id, 9) == :managed
      assert get_account(account2_id).total == 1
    end

    test "withdraw without funds" do
      account1_id = TestHelper.new_number()
      assert deposit(account1_id, 100) == :managed

      account2_id = TestHelper.new_number()
      assert deposit(account2_id, 10) == :managed

      assert withdraw(account1_id, 101) == {:error, "no funds"}
      assert get_account(account1_id).total == 100

      assert withdraw(account2_id, 11) == {:error, "no funds"}
      assert get_account(account2_id).total == 10
    end

    test "add goods" do
      account_id = TestHelper.new_number()
      assert add_goods(account_id, 100) == :managed

      assert get_account(account_id).goods == 105
    end

    test "remove goods" do
      account_id = TestHelper.new_number()
      assert remove_goods(account_id, 5) == :managed

      assert get_account(account_id).goods == 0
    end
  end

  describe "Process persistence tester" do
    test "kill and resume: check state" do
      Process.flag(:trap_exit, true)

      process_id = TestHelper.new_id()
      new_persisted_process(process_id)

      assert get_persisted_process(process_id).status == "started"

      pid = kill_process(process_id)
      refute Process.alive?(pid)

      Process.sleep(500)

      assert get_persisted_process(process_id).status == "started"
      Process.flag(:trap_exit, false)
    end

    test "kill and resume: check if it still responds to events" do
      Process.flag(:trap_exit, true)

      process_id = TestHelper.new_id()
      new_persisted_process(process_id)

      assert get_persisted_process(process_id).status == "started"

      pid = kill_process(process_id)
      refute Process.alive?(pid)

      Process.sleep(100)

      key = Atom.to_string(SevenottersTester.PersistedProcess) <> "_" <> process_id

      event = Seven.Otters.Event.create("TouchPersistedProcess", %{}, SevenottersTester.PersistedProcess)
      event = %{event | counter: 0, request_id: TestHelper.new_id(), process_id: key, correlation_id: key}
      Seven.Utils.Events.trigger([event])

      Process.sleep(100)

      assert get_persisted_process(process_id).status == "touched"
      Process.flag(:trap_exit, false)
    end
  end

  describe "Process tester" do
    test "buy something: ok" do
      account1_id = TestHelper.new_number()
      deposit(account1_id, 100)

      account2_id = TestHelper.new_number()
      deposit(account2_id, 10)

      Seven.EventStore.EventStore.subscribe("GoodsBought", self())
      request_id = TestHelper.new_id()
      process_id = TestHelper.new_id()

      assert buy_goods(request_id, process_id, account1_id, 5, account2_id) == :managed

      assert_receive %Seven.Otters.Event{type: "GoodsBought", request_id: ^request_id, correlation_module: SevenottersTester.BuyGoods}

      assert process_unloaded(process_id, 10) == :ok

      account1 = get_account(account1_id)
      assert account1.total == 105
      assert account1.goods == 0

      account2 = get_account(account2_id)
      assert account2.total == 5
      assert account2.goods == 10
    end

    test "buy something: no funds - no start" do
      account1_id = TestHelper.new_number()
      deposit(account1_id, 100)

      account2_id = TestHelper.new_number()
      deposit(account2_id, 0)

      Seven.EventStore.EventStore.subscribe("BuyGoodsErrorOccurred", self())
      request_id = TestHelper.new_id()
      process_id = TestHelper.new_id()

      assert buy_goods(request_id, process_id, account1_id, 5, account2_id) == {:error, "no funds"}

      assert_receive %Seven.Otters.Event{type: "BuyGoodsErrorOccurred", request_id: ^request_id, correlation_module: SevenottersTester.BuyGoods, payload: %{reason: "no funds"}}

      assert process_unloaded(process_id, 10) == :ok

      account1 = get_account(account1_id)
      assert account1.total == 100
      assert account1.goods == 5

      account2 = get_account(account2_id)
      assert account2.total == 0
      assert account2.goods == 5
    end

    test "buy something: no enougth goods - rollback" do
      account1_id = TestHelper.new_number()
      deposit(account1_id, 100)

      account2_id = TestHelper.new_number()
      deposit(account2_id, 10)

      Seven.EventStore.EventStore.subscribe("BuyGoodsErrorOccurred", self())
      request_id = TestHelper.new_id()
      process_id = TestHelper.new_id()

      assert buy_goods(request_id, process_id, account1_id, 10, account2_id) == :managed

      assert_receive %Seven.Otters.Event{type: "BuyGoodsErrorOccurred", request_id: ^request_id, correlation_module: SevenottersTester.BuyGoods, payload: %{reason: "no enought goods"}}

      assert process_unloaded(process_id, 10) == :ok

      account1 = get_account(account1_id)
      assert account1.total == 100
      assert account1.goods == 5

      account2 = get_account(account2_id)
      assert account2.total == 10
      assert account2.goods == 5
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

  defp get_persisted_process(id) do
    SevenottersTester.PersistedProcess
    |> TestHelper.get_registered_item(id)
    |> SevenottersTester.PersistedProcess.state()
    |> assert()
    |> Map.get(:internal_state)
  end

  defp new_persisted_process(id) do
    %Seven.CommandRequest{
      id: TestHelper.new_id(),
      command: "StartPersistedProcess",
      sender: __MODULE__,
      params: %{id: id}
    }
    |> Seven.CommandBus.send_command_request()
  end

  defp withdraw(id, amount) do
    %Seven.CommandRequest{
      id: TestHelper.new_id(),
      command: "WithdrawAmount",
      sender: __MODULE__,
      params: %{id: id, amount: amount}
    }
    |> Seven.CommandBus.send_command_request()
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

  defp add_goods(id, goods) do
    %Seven.CommandRequest{
      id: TestHelper.new_id(),
      command: "AddGoods",
      sender: __MODULE__,
      params: %{id: id, goods: goods}
    }
    |> Seven.CommandBus.send_command_request()
  end

  defp remove_goods(id, goods) do
    %Seven.CommandRequest{
      id: TestHelper.new_id(),
      command: "RemoveGoods",
      sender: __MODULE__,
      params: %{id: id, goods: goods}
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

  defp kill_process(process_id) do
    SevenottersTester.PersistedProcess
    |> TestHelper.get_registered_item(process_id)
    |> kill()
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
end
