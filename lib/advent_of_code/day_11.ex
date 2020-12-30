defmodule AdventOfCode.Day11 do
  @black 0
  @white 1

  @left 0
  @right 1

  def part1(input) do
    intcode =
      input
      |> parse()
      |> Intcode.new()

    walk_hull(Map.new(), {0, 0}, :up, intcode, 0)
    |> Enum.count()
  end

  def part2(input) do
    intcode =
      input
      |> parse()
      |> Intcode.new()

    walk_hull(Map.new(), {0, 0}, :up, intcode, 1)
    |> visualize()
  end

  def walk_hull(hull, pos, dir, intcode, input) do
    intcode = Intcode.set_input(intcode, input)

    case Intcode.run_until_output(intcode) do
      {:out, intcode = %{output: [dir_change, color]}} ->
        new_hull = paint_panel(hull, pos, color)
        new_dir = change_dir(dir, dir_change)
        new_pos = move_robot(pos, new_dir)
        new_input = Map.get(new_hull, new_pos, @black)
        # reset output
        new_intcode = %{intcode | output: []}

        walk_hull(new_hull, new_pos, new_dir, new_intcode, new_input)

      # only 1 element in output, wait for the second one
      {:out, intcode = %{output: [_color]}} ->
        walk_hull(hull, pos, dir, intcode, input)

      {:halt, _} ->
        hull
    end
  end

  def paint_panel(hull, pos, color), do: Map.put(hull, pos, color)

  def change_dir(:up, @left), do: :left
  def change_dir(:right, @left), do: :up
  def change_dir(:down, @left), do: :right
  def change_dir(:left, @left), do: :down

  def change_dir(:up, @right), do: :right
  def change_dir(:right, @right), do: :down
  def change_dir(:down, @right), do: :left
  def change_dir(:left, @right), do: :up

  def move_robot({x, y}, :up), do: {x, y - 1}
  def move_robot({x, y}, :right), do: {x + 1, y}
  def move_robot({x, y}, :down), do: {x, y + 1}
  def move_robot({x, y}, :left), do: {x - 1, y}

  def visualize(hull) do
    {min_x, max_x} = hull |> Map.keys() |> Enum.map(fn {x, _} -> x end) |> Enum.min_max()
    {min_y, max_y} = hull |> Map.keys() |> Enum.map(fn {_, y} -> y end) |> Enum.min_max()

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        case Map.get(hull, {x, y}, @black) do
          @black -> " "
          @white -> "#"
        end
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
    |> IO.puts()
  end

  def parse(input) do
    input |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
  end
end
