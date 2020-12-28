defmodule AdventOfCode.Day01 do
  def part1(input) do
    input
    |> parse()
    |> Enum.map(&calc_fuel/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse()
    |> Enum.map(&calc_actual_fuel/1)
    |> Enum.sum()
  end

  def calc_fuel(mass) do
    mass |> div(3) |> Kernel.-(2)
  end

  def calc_actual_fuel(mass) do
    case calc_fuel(mass) do
      fuel when fuel < 0 -> 0
      fuel -> fuel + calc_actual_fuel(fuel)
    end
  end

  def parse(input) do
    input |> String.split("\n", trim: true) |> Enum.map(&String.to_integer/1)
  end
end
