defmodule CommandValidationTest do
  use ExUnit.Case

  describe "Syntax validation" do
    test "send invalid data in command" do
      number = TestHelper.new_number()

      result =
        %Seven.CommandRequest{
          id: TestHelper.new_id(),
          command: "ApplySyntaxValidation",
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
          command: "ApplySyntaxValidation",
          sender: __MODULE__,
          params: %{number: number, data: :good}
        }
        |> Seven.CommandBus.send_command_request()

      assert result == :managed
      assert TestHelper.get_aggregate(SevenottersTester.CommandValidationTester, number)
    end
  end

  describe "Semantic validation" do
    test "send invalid data in command" do
      number = TestHelper.new_number()

      result =
        %Seven.CommandRequest{
          id: TestHelper.new_id(),
          command: "ApplySemanticValidation",
          sender: __MODULE__,
          params: %{number: number, data: :invalid_semantic_data}
        }
        |> Seven.CommandBus.send_command_request()

      assert result == {:routed_but_invalid, "invalid_semantic_data"}
      assert TestHelper.get_aggregate(SevenottersTester.CommandValidationTester, number)
    end

    test "send valid data in command" do
      number = TestHelper.new_number()

      result =
        %Seven.CommandRequest{
          id: TestHelper.new_id(),
          command: "ApplySemanticValidation",
          sender: __MODULE__,
          params: %{number: number, data: :valid_semantic_data}
        }
        |> Seven.CommandBus.send_command_request()

      assert result == :managed
      assert TestHelper.get_aggregate(SevenottersTester.CommandValidationTester, number)
    end

    test "send invalid data in command for useless aggregate" do
      number = TestHelper.new_number()

      result =
        %Seven.CommandRequest{
          id: TestHelper.new_id(),
          command: "ApplySemanticValidation",
          sender: __MODULE__,
          params: %{number: number, data: :useless_aggregate_data}
        }
        |> Seven.CommandBus.send_command_request()

      assert result == "useless_aggregate_data"
      Process.sleep(500)
      refute TestHelper.get_aggregate(SevenottersTester.CommandValidationTester, number)
    end

    test "send invalid data in command for useless aggregate on command" do
      number = TestHelper.new_number()

      result =
        %Seven.CommandRequest{
          id: TestHelper.new_id(),
          command: "ApplySemanticValidationOnCommand",
          sender: __MODULE__,
          params: %{number: number, data: :useless_aggregate_data}
        }
        |> Seven.CommandBus.send_command_request()

      assert result == "useless_aggregate_data"
      Process.sleep(500)
      refute TestHelper.get_aggregate(SevenottersTester.CommandValidationTester, number)
    end
  end
end
