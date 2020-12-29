defmodule AdventOfCode.Day09 do
  def part1(input) do
    input
    |> parse()
    |> Intcode.new(1)
    |> Intcode.run()
    |> Map.get(:output)
    |> hd()
  end

  def part2(input) do
    input
    |> parse()
    |> Intcode.new(2)
    |> Intcode.run()
    |> Map.get(:output)
    |> hd()
  end

  def parse(input) do
    input |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
  end
end
