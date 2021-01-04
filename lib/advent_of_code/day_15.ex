defmodule AdventOfCode.Day15 do
  @north 1
  @south 2
  @west 3
  @east 4

  @wall 0
  @step 1
  @oxygen 2

  def part1(input) do
    intcode = input |> parse() |> Intcode.new()

    walk(Map.new(), intcode, {0, 0})
  end

  def part2(input) do
    grid = part1(input)

    oxygen = grid |> Enum.find(fn {_, v} -> v == @oxygen end) |> elem(0)

    fill(grid, oxygen) |> elem(1)
  end

  def walk(grid, intcode, point, steps \\ 0) do
    Enum.reduce(directions(), grid, fn dir, grid ->
      point = move(point, dir)

      if point in Map.keys(grid) do
        grid
      else
        case intcode |> Intcode.set_input(dir) |> Intcode.run_until_output() do
          {:out, %{output: [@wall | _]}} ->
            Map.put(grid, point, @wall)

          {:out, intcode = %{output: [@step | _]}} ->
            grid = Map.put(grid, point, @step)
            walk(grid, intcode, point, steps + 1)

          {:out, %{output: [@oxygen | _]}} ->
            IO.puts(steps + 1)
            Map.put(grid, point, @oxygen)
        end
      end
    end)
  end

  def fill(grid, point, steps \\ 0, max_steps \\ 0) do
    Enum.reduce(directions(), {grid, max_steps}, fn dir, {grid, max_steps} ->
      point = move(point, dir)

      if {point, @oxygen} in grid || {point, @wall} in grid do
        {grid, max(max_steps, steps)}
      else
        grid = Map.put(grid, point, @oxygen)
        fill(grid, point, steps + 1, max(max_steps, steps + 1))
      end
    end)
  end

  def directions, do: [@north, @south, @east, @west]
  def move({x, y}, @north), do: {x, y + 1}
  def move({x, y}, @south), do: {x, y - 1}
  def move({x, y}, @west), do: {x - 1, y}
  def move({x, y}, @east), do: {x + 1, y}

  def visualize(grid) do
    {min_x, max_x} = grid |> Map.keys() |> Enum.map(fn {x, _} -> x end) |> Enum.min_max()
    {min_y, max_y} = grid |> Map.keys() |> Enum.map(fn {_, y} -> y end) |> Enum.min_max()

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        case Map.get(grid, {x, y}, @wall) do
          @step -> " "
          @wall -> IO.ANSI.blue_background() <> " " <> IO.ANSI.reset()
          @oxygen -> IO.ANSI.yellow() <> "O" <> IO.ANSI.reset()
        end
      end
      |> Enum.join()
      |> IO.write()

      IO.write("\n")
    end
  end

  def parse(input) do
    input |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
  end
end
