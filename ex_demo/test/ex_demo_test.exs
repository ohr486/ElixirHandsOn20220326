defmodule ExDemoTest do
  use ExUnit.Case
  doctest ExDemo

  test "greets the world" do
    assert ExDemo.hello() == :world
  end
end
