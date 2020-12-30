defmodule AdventOfCode.Day10 do
  def part1(input) do
    asteroids = parse(input)

    asteroids
    |> Enum.map(&reachable_asteroids(&1, asteroids))
    |> Enum.max()
  end

  def part2(input) do
    asteroids = parse(input)

    monitoring =
      asteroids
      |> Enum.map(fn a -> {a, reachable_asteroids(a, asteroids)} end)
      |> Enum.max_by(fn {_, n} -> n end)
      |> elem(0)

    {first, last} =
      asteroids
      |> MapSet.delete(monitoring)
      |> Enum.map(fn a -> {a, calc_angle(monitoring, a)} end)
      |> Enum.sort_by(&manhattan_dist(elem(&1, 0), monitoring), &>=/2)
      |> Enum.sort_by(&elem(&1, 1))
      |> Enum.split_with(fn {_, angle} -> angle >= :math.atan2(-1, 0) end)

    {x, y} =
      (first ++ last)
      |> vaporization_sequence()
      |> Enum.at(200 - 1)

    x * 100 + y
  end

  def reachable_asteroids(asteroid, asteroids) do
    asteroids
    |> MapSet.delete(asteroid)
    |> Enum.map(&calc_angle(asteroid, &1))
    |> Enum.uniq()
    |> Enum.count()
  end

  def vaporization_sequence(asteroids) do
    asteroids
    |> Enum.map(fn {_, angle} -> angle end)
    |> Enum.uniq()
    |> Stream.cycle()
    |> Enum.reduce_while({asteroids, []}, fn angle, {to_parse, acc} ->
      maybe_next = Enum.find(to_parse, fn {_, a} -> angle == a end)

      cond do
        to_parse == [] -> {:halt, Enum.reverse(acc)}
        maybe_next == nil -> {:cont, {to_parse, acc}}
        true -> {:cont, {List.delete(to_parse, maybe_next), [maybe_next | acc]}}
      end
    end)
    |> Enum.map(fn {p, _angle} -> p end)
  end

  def calc_angle({x1, y1}, {x2, y2}) do
    :math.atan2(y2 - y1, x2 - x1)
  end

  def manhattan_dist({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 + y2)
  end

  def parse(input) do
    rows =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.codepoints/1)

    for {row, row_i} <- Enum.with_index(rows),
        {col, col_i} <- Enum.with_index(row),
        col == "#",
        into: MapSet.new(),
        do: {col_i, row_i}
  end
end
