defmodule SevenottersTester.CommandValidationTester do
  use Seven.Otters.Aggregate, aggregate_field: :number

  defstruct number: nil

  @apply_syntax_validation_command "ApplySyntaxValidation"
  @apply_semantic_validation_command "ApplySemanticValidation"
  @apply_semantic_validation_on_command_command "ApplySemanticValidationOnCommand"

  @moduledoc """
    Aggregate to test command validation.
    Responds to commands:
    - #{@apply_syntax_validation_command}
    - #{@apply_semantic_validation_command}
    - #{@apply_semantic_validation_on_command_command}
  """

  defp init_state, do: %__MODULE__{}

  @spec route(String.t(), any) :: {:routed, Map.y(), atom} | {:invalid, Map.t()}
  def route(@apply_syntax_validation_command, params) do
    cmd = %{
      number: params[:number],
      data: params[:data]
    }

    @apply_syntax_validation_command
    |> Seven.Otters.Command.create(cmd)
    |> validate_param()
  end

  def route(@apply_semantic_validation_command, params) do
    cmd = %{
      number: params[:number],
      data: params[:data]
    }

    @apply_semantic_validation_command
    |> Seven.Otters.Command.create(cmd)
    |> validate_param()
  end

  def route(@apply_semantic_validation_on_command_command, params) do
    cmd = %{
      number: params[:number],
      data: params[:data]
    }

    @apply_semantic_validation_on_command_command
    |> Seven.Otters.Command.create(cmd)
    |> validate_param()
  end

  def route(_command, _params), do: :not_routed

  defp pre_handle_command(%Seven.Otters.Command{type: @apply_semantic_validation_command, payload: %{data: :invalid_semantic_data}} = _command, _state) do
    {:routed_but_invalid, "invalid_semantic_data"}
  end

  defp pre_handle_command(%Seven.Otters.Command{type: @apply_semantic_validation_command, payload: %{data: :useless_aggregate_data}} = _command, _state) do
    {:no_aggregate, "useless_aggregate_data"}
  end

  defp pre_handle_command(_command, _state), do: :ok

  defp handle_command(%Seven.Otters.Command{type: @apply_syntax_validation_command} = _command, _state) do
    {:managed, []}
  end

  defp handle_command(%Seven.Otters.Command{type: @apply_semantic_validation_command} = _command, _state) do
    {:managed, []}
  end

  defp handle_command(%Seven.Otters.Command{type: @apply_semantic_validation_on_command_command} = _command, _state) do
    {:no_aggregate, "useless_aggregate_data"}
  end

  defp handle_event(_event, state), do: state

  #
  # Private
  #
  defp validate_param(%Seven.Otters.Command{payload: %{data: :bad}}), do: {:routed_but_invalid, "invalid_data"}
  defp validate_param(%Seven.Otters.Command{} = command), do: {:routed, command, __MODULE__}
end
