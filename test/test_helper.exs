Seven.Test.Helper.drop_events()
Seven.Test.Helper.drop_processes()
Seven.Test.Helper.clean_projections()

ExUnit.start()

defmodule TestHelper do
  @spec new_number() :: bitstring
  def new_number(), do: Seven.Data.Persistence.new_id() |> Seven.Data.Persistence.printable_id()

  @spec new_id() :: bitstring
  def new_id(), do: Seven.Data.Persistence.new_id() |> Seven.Data.Persistence.printable_id()

  @spec get_registered_item(atom, bitstring) :: bitstring
  def get_registered_item(module, correlation_id), do: Seven.Registry.is_loaded(module, correlation_id)
end
