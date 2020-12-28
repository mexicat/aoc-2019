defmodule AdventOfCode.Day02 do
  def part1(input) do
    input
    |> parse()
    |> List.replace_at(1, 12)
    |> List.replace_at(2, 2)
    |> Intcode.new()
    |> Intcode.run()
    |> Map.get(:ops)
    |> Enum.at(0)
  end

  def part2(input) do
    ops = input |> parse()

    {noun, verb} =
      for x <- 0..99,
          y <- 0..99,
          ops
          |> List.replace_at(1, x)
          |> List.replace_at(2, y)
          |> Intcode.new()
          |> Intcode.run()
          |> Map.get(:ops)
          |> Enum.at(0)
          |> Kernel.==(19_690_720) do
        {x, y}
      end
      |> hd()

    100 * noun + verb
  end

  def parse(input) do
    input |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
  end
end
