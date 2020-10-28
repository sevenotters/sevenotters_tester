defmodule TesterAggregateTest do
  use SevenottersTester.ModelCase

  describe "Tester aggregate" do
    test "send events and check state" do
      {:ok, aggregate_pid} = SevenottersTester.TesterAggregate.start_link(UUID.uuid4(:hex))

      Seven.Otters.Event.create("NameChanged", %{v1: %{new_name: "Pino"}}, __MODULE__)
      |> SevenottersTester.TesterAggregate.send(aggregate_pid)

      Seven.Otters.Event.create("NameChanged", %{v1: %{new_name: "Gino"}}, __MODULE__)
      |> SevenottersTester.TesterAggregate.send(aggregate_pid)

      assert SevenottersTester.TesterAggregate.state(aggregate_pid).internal_state.name == "Gino"
    end
  end
end
