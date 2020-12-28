defmodule AdventOfCode.Day03 do
  def part1(input) do
    {w1, w2} = parse(input)

    {_, w1_points} = Enum.reduce(w1, {{0, 0}, []}, &traverse_path/2)
    {_, w2_points} = Enum.reduce(w2, {{0, 0}, []}, &traverse_path/2)

    MapSet.intersection(MapSet.new(w1_points), MapSet.new(w2_points))
    |> Enum.map(&manhattan_dist(&1, {0, 0}))
    |> Enum.sort()
    |> hd()
  end

  def part2(input) do
    {w1, w2} = parse(input)

    {_, w1_points} = Enum.reduce(w1, {{0, 0}, []}, &traverse_path/2)
    {_, w2_points} = Enum.reduce(w2, {{0, 0}, []}, &traverse_path/2)

    MapSet.intersection(MapSet.new(w1_points), MapSet.new(w2_points))
    |> Enum.map(fn point ->
      # +2 compensates for the lack of initial step
      Enum.find_index(w1_points, &(&1 == point)) + Enum.find_index(w2_points, &(&1 == point)) + 2
    end)
    |> Enum.sort()
    |> hd()
  end

  def traverse_path({dir, amt}, {start, visited}) do
    {curr, prev} = move(dir, amt, start, [])
    {curr, visited ++ prev}
  end

  def move(_, 0, curr, prev), do: {curr, Enum.reverse(prev)}

  def move(:right, n, {x, y}, prev),
    do: move(:right, n - 1, {x + 1, y}, [{x + 1, y} | prev])

  def move(:down, n, {x, y}, prev),
    do: move(:down, n - 1, {x, y - 1}, [{x, y - 1} | prev])

  def move(:left, n, {x, y}, prev),
    do: move(:left, n - 1, {x - 1, y}, [{x - 1, y} | prev])

  def move(:up, n, {x, y}, prev),
    do: move(:up, n - 1, {x, y + 1}, [{x, y + 1} | prev])

  def manhattan_dist({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)

  def parse(input) do
    [w1, w2] = input |> String.split("\n", trim: true)
    {parse_path(w1), parse_path(w2)}
  end

  def parse_path(wire) do
    wire
    |> String.split(",", trim: true)
    |> Enum.map(fn dir ->
      case dir do
        "R" <> rest -> {:right, String.to_integer(rest)}
        "D" <> rest -> {:down, String.to_integer(rest)}
        "L" <> rest -> {:left, String.to_integer(rest)}
        "U" <> rest -> {:up, String.to_integer(rest)}
      end
    end)
  end
end
