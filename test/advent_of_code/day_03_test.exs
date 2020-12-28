defmodule AdventOfCode.Day01Test do
  use ExUnit.Case

  import AdventOfCode.Day03

  @input1 """
  R8,U5,L5,D3
  U7,R6,D4,L4
  """

  @input2 """
  R75,D30,R83,U83,L12,D49,R71,U7,L72
  U62,R66,U55,R34,D71,R55,D58,R83
  """

  # @tag :skip
  test "part2" do
    assert part2(@input1) == 30
    assert part2(@input2) == 610
  end
end
