defmodule NinerTest do
  use ExUnit.Case
  doctest Niner

  test "greets the world" do
    assert Niner.hello() == :world
  end
end
