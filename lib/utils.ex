defmodule SevenottersTester.Utils do
  def new_persisted_process(id) do
    :managed =
      %Seven.CommandRequest{
        id: Seven.Data.Persistence.new_id() |> Seven.Data.Persistence.printable_id(),
        command: "StartPersistedProcess",
        sender: __MODULE__,
        params: %{id: id}
      }
      |> Seven.CommandBus.send_command_request()

    Atom.to_string(SevenottersTester.PersistedProcess) <> "_" <> id
  end
end
