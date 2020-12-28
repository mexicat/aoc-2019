defmodule AdventOfCode.Day04 do
  def part1(input) do
    input
    |> parse()
    |> Enum.count(fn n ->
      n = Integer.digits(n)
      doubles?(n) && increasing?(n)
    end)
  end

  def part2(input) do
    input
    |> parse()
    |> Enum.count(fn n ->
      n = Integer.digits(n)
      just_one_double?(n) && increasing?(n)
    end)
  end

  def just_one_double?(digits) do
    2 in (digits |> Enum.frequencies() |> Map.values())
  end

  def doubles?(digits), do: length(Enum.dedup(digits)) < length(digits)

  def increasing?([a, b, c, d, e, f]) when a <= b and b <= c and c <= d and d <= e and e <= f,
    do: true

  def increasing?(_), do: false

  def parse(input) do
    [a, b] = input |> String.trim() |> String.split("-") |> Enum.map(&String.to_integer/1)
    a..b
  end
end
