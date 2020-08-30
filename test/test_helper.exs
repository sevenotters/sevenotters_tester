Seven.Test.Helper.drop_events()
Seven.Test.Helper.drop_snapshots()
Seven.Test.Helper.clean_projections()

ExUnit.start()

defmodule TestHelper do
  @spec new_number() :: String
  def new_number(), do: Seven.Data.Persistence.new_id() |> Seven.Data.Persistence.printable_id()

  @spec new_id() :: String
  def new_id(), do: Seven.Data.Persistence.new_id() |> Seven.Data.Persistence.printable_id()

  @spec get_aggregate(atom(), String) :: String
  def get_aggregate(module, correlation_id), do: Seven.Registry.is_loaded(module, correlation_id)
end
