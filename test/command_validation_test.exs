defmodule CommandValidationTest do
  use ExUnit.Case

  test "send invalid data in command" do
    number = TestHelper.new_number()

    result =
      %Seven.CommandRequest{
        id: TestHelper.new_id(),
        command: "ApplySyntactValidation",
        sender: __MODULE__,
        params: %{number: number, data: :bad}
      }
      |> Seven.CommandBus.send_command_request()

    assert result == {:routed_but_invalid, "invalid_data"}
    refute TestHelper.get_aggregate(SevenottersTester.CommandValidationTester, number)
  end

  test "send valid data in command" do
    number = TestHelper.new_number()

    result =
      %Seven.CommandRequest{
        id: TestHelper.new_id(),
        command: "ApplySyntactValidation",
        sender: __MODULE__,
        params: %{number: number, data: :good}
      }
      |> Seven.CommandBus.send_command_request()

    assert result == :managed
    assert TestHelper.get_aggregate(SevenottersTester.CommandValidationTester, number)
  end
end
