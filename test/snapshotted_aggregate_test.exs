defmodule SnapshottedAggregateTest do
  use ExUnit.Case, async: false

  describe "Tester snapshotted aggregate" do
    test "snapshot is created: non other events" do
      number = TestHelper.new_number()

      send_add_coins_commands(1000, number)

      aggregate = get_aggregate(number)
      assert aggregate.snapshot.events_to_snapshot == 0

      snapshot = get_snapshot(aggregate.correlation_id)
      assert snapshot
    end

    test "snapshot is created: some events not in snapshot" do
      number = TestHelper.new_number()

      send_add_coins_commands(999, number)

      aggregate = get_aggregate(number)
      assert aggregate.snapshot.events_to_snapshot == 99

      snapshot = get_snapshot(aggregate.correlation_id)
      assert snapshot
    end

    test "load from snapshot" do
      Process.flag(:trap_exit, true)

      number = TestHelper.new_number()
      send_add_coins_commands(100, number)

      old_state = get_aggregate(number)
      kill_aggregate(number)

      send_wake_up_commands(number)
      Process.sleep(200)

      new_state = get_aggregate(number)
      Process.flag(:trap_exit, false)

      assert old_state.correlation_id == new_state.correlation_id
      assert old_state.internal_state == new_state.internal_state
      assert old_state.snapshot == new_state.snapshot
    end
  end

  def kill(pid, timeout \\ 1_000) do
    true = Process.alive?(pid)
    ref = Process.monitor(pid)
    Process.exit(pid, :kill)
    receive do
       {:DOWN, ^ref, :process, ^pid, _reason} ->
        refute Process.alive?(pid)
        :ok
    after
      timeout -> :timeout
    end
  end

  defp get_snapshot(correlation_id) do
    Seven.Data.Persistence.snapshots()
    |> Enum.map(fn s -> AtomicMap.convert(s, safe: false) end)
    |> Enum.find(fn s -> s.correlation_id == correlation_id end)
  end

  defp kill_aggregate(number) do
    SevenottersTester.SnapshottedAggregate
    |> TestHelper.get_aggregate(number)
    |> kill()
  end

  defp get_aggregate(number) do
    SevenottersTester.SnapshottedAggregate
    |> TestHelper.get_aggregate(number)
    |> SevenottersTester.SnapshottedAggregate.state()
    |> assert()
  end

  defp send_add_coins_commands(n, number) do
    1..n
    |> Enum.each(fn coins ->
      result =
        %Seven.CommandRequest{
          id: TestHelper.new_id(),
          command: "AddCoins",
          sender: __MODULE__,
          params: %{number: number, coins: coins}
        }
        |> Seven.CommandBus.send_command_request()

      assert result == :managed
    end)
  end

  defp send_wake_up_commands(number) do
    %Seven.CommandRequest{
      id: TestHelper.new_id(),
      command: "WakeUp",
      sender: __MODULE__,
      params: %{number: number}
    }
    |> Seven.CommandBus.send_command_request()
  end
end
