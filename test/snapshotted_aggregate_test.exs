defmodule SnapshottedAggregateTest do
  use ExUnit.Case

  describe "Tester snapshotted aggregate" do
    test "snapshot is created: non other events" do
      wallet_number = TestHelper.new_number()

      send_add_coins_commands(wallet_number, 1000)
      Process.sleep(100)

      aggregate = get_aggregate(wallet_number)
      assert aggregate.snapshot.events_to_snapshot == 0

      snapshot = get_snapshot(aggregate.correlation_id)
      assert snapshot
    end

    test "snapshot is created: some events not in snapshot" do
      wallet_number = TestHelper.new_number()

      send_add_coins_commands(wallet_number, 999)
      Process.sleep(100)

      aggregate = get_aggregate(wallet_number)
      assert aggregate.snapshot.events_to_snapshot == 99

      snapshot = get_snapshot(aggregate.correlation_id)
      assert snapshot
    end

    [0..220, 290..310]
    |> Enum.reduce([], fn r, acc -> Enum.to_list(r) ++ acc end)
    |> Enum.sort()
    |> Enum.each(fn n ->
      test "load from snapshot - #{n} commands" do
        Process.flag(:trap_exit, true)

        wallet_number = TestHelper.new_number()

        send_add_coins_commands(wallet_number, unquote(n))
        Process.sleep(100)

        old_state = get_aggregate(wallet_number)
        kill_aggregate(wallet_number)

        send_wake_up_commands(wallet_number)
        Process.sleep(100)

        new_state = get_aggregate(wallet_number)
        Process.flag(:trap_exit, false)

        assert old_state.correlation_id == new_state.correlation_id
        assert old_state.internal_state == new_state.internal_state
        assert old_state.snapshot == new_state.snapshot
      end
    end)
  end

  describe "Tester snapshotted projection" do
    test "snapshot is created: non other events" do
      wallet_number = SevenottersTester.SnapshotTesterProjection.special_id()

      send_add_coins_commands(wallet_number, 1000)
      Process.sleep(100)

      events_in_proj = SevenottersTester.SnapshotTesterProjection.query(:events, nil)
      assert events_in_proj == 1000

      SevenottersTester.SnapshotTesterProjection.pid() |> kill()
      wait_for_projection(20)

      events_in_proj = SevenottersTester.SnapshotTesterProjection.query(:events, nil)
      assert events_in_proj == 1000
    end
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

  defp wait_for_projection(0), do: :timeout
  defp wait_for_projection(n) do
    Process.sleep(100)
    if not is_pid(SevenottersTester.SnapshotTesterProjection.pid()), do: wait_for_projection(n - 1)
  end

  defp wait_for_unload(_number, 0), do: :timeout
  defp wait_for_unload(number, n) do
    Process.sleep(10)
    if Seven.Aggregates.is_loaded(SevenottersTester.SnapshottedAggregate, number), do: wait_for_unload(number, n - 1)
  end

  defp get_snapshot(correlation_id) do
    Seven.Data.Persistence.snapshots()
    # |> Enum.map(fn s -> AtomicMap.convert(s, safe: false) end)
    |> Enum.find(fn s -> s.correlation_id == correlation_id end)
  end

  defp kill_aggregate(number) do
    SevenottersTester.SnapshottedAggregate
    |> TestHelper.get_aggregate(number)
    |> kill()

    wait_for_unload(number, 50)
  end

  defp get_aggregate(number) do
    SevenottersTester.SnapshottedAggregate
    |> TestHelper.get_aggregate(number)
    |> SevenottersTester.SnapshottedAggregate.state()
    |> assert()
  end

  defp send_add_coins_commands(wallet_number, number) do
    1..number
    |> Enum.each(fn coins ->
      result =
        %Seven.CommandRequest{
          id: TestHelper.new_id(),
          command: "AddCoins",
          sender: __MODULE__,
          params: %{number: wallet_number, coins: coins}
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
