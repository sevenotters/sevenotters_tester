defmodule TesterProjectionTest do
  use ExUnit.Case

  describe "Tester projection" do
    test "send events and check state" do
      proj_name = :my_calculator
      SevenottersTester.TesterProjection.start_link(name: proj_name, subscribe_to_eventstore: false)

      Seven.Otters.Event.create("ValueAdded", %{v1: %{value: 5}}, __MODULE__)
      |> SevenottersTester.TesterProjection.send(proj_name)

      Seven.Otters.Event.create("ValueAdded", %{v1: %{value: 3}}, __MODULE__)
      |> SevenottersTester.TesterProjection.send(proj_name)

      assert SevenottersTester.TesterProjection.state(proj_name) == 8
    end
  end
end
