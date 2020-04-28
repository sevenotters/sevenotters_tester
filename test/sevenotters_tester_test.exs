defmodule SevenottersTesterTest do
  use ExUnit.Case
  doctest SevenottersTester

  test "greets the world" do
    assert SevenottersTester.hello() == :world
  end
end
