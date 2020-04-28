defmodule SevenottersTester.CommandValidationTester do
  use Seven.Otters.Aggregate, aggregate_field: :number

  defstruct number: nil

  @apply_syntact_validation_command "ApplySyntactValidation"

  @moduledoc """
    Aggregate to test command validation.
    Responds to commands:
    - #{@apply_syntact_validation_command}
  """

  defp init_state, do: %__MODULE__{}

  @spec route(String.t(), any) :: {:routed, Map.y(), atom} | {:invalid, Map.t()}
  def route(@apply_syntact_validation_command, params) do
    cmd = %{
      number: params[:number],
      data: params[:data]
    }

    @apply_syntact_validation_command
    |> Seven.Otters.Command.create(cmd)
    |> validate_param()
  end

  def route(_command, _params), do: :not_routed

  defp pre_handle_command(_command, _state), do: :ok

  @spec handle_command(Map.t(), any) :: {:managed, List.t()}
  defp handle_command(%Seven.Otters.Command{type: @apply_syntact_validation_command} = _command, _state) do
    {:managed, []}
  end

  defp handle_event(_event, state), do: state

  #
  # Private
  #
  defp validate_param(%Seven.Otters.Command{payload: %{data: :bad}}), do: {:routed_but_invalid, "invalid_data"}
  defp validate_param(%Seven.Otters.Command{} = command), do: {:routed, command, __MODULE__}
end
