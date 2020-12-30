defmodule AdventOfCode.Day13 do
  @empty 0
  @wall 1
  @block 2
  @paddle 3
  @ball 4

  def part1(input) do
    intcode =
      input
      |> parse()
      |> Intcode.new()

    play(Map.new(), intcode)
    |> Enum.count(fn {_, v} -> v == @block end)
  end

  def part2(input) do
    intcode =
      input
      |> parse()
      |> List.replace_at(0, 2)
      |> Intcode.new()

    IO.puts(IO.ANSI.clear())
    # hide cursor
    IO.puts("\x1b[?25l")

    play(Map.new(), intcode)
  end

  def play(grid, intcode) do
    # this line enables animations
    if map_size(grid) > 0, do: visualize(grid)

    case Intcode.run_until_output(intcode) do
      {:out, intcode = %{output: [score, 0, -1]}} ->
        IO.inspect(score, label: "\n\n score")
        new_intcode = %{intcode | output: []}
        play(grid, new_intcode)

      {:out, intcode = %{output: [tile_id, y, x]}} ->
        new_grid = Map.put(grid, {x, y}, tile_id)

        input =
          if tile_id == @ball do
            paddle = Enum.find(grid, fn {_pos, tile} -> tile == @paddle end)

            case paddle do
              nil -> nil
              {{paddle_x, _}, _} when paddle_x > x -> -1
              {{paddle_x, _}, _} when paddle_x < x -> 1
              _ -> 0
            end
          end

        new_intcode = %{intcode | output: [], input: input}

        play(new_grid, new_intcode)

      # less than 3 elements in output, wait to fill
      {:out, intcode} ->
        play(grid, intcode)

      {:halt, _} ->
        grid
    end
  end

  def visualize(grid) do
    {min_x, max_x} = grid |> Map.keys() |> Enum.map(fn {x, _} -> x end) |> Enum.min_max()
    {min_y, max_y} = grid |> Map.keys() |> Enum.map(fn {_, y} -> y end) |> Enum.min_max()

    # uncomment to slow down animation
    # if Enum.find(grid, fn {_pos, tile} -> tile == @paddle end), do: Process.sleep(10)

    IO.puts(IO.ANSI.cursor(0, 0))

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        case Map.get(grid, {x, y}, @empty) do
          @empty -> " "
          @wall -> IO.ANSI.blue_background() <> " " <> IO.ANSI.reset()
          @block -> IO.ANSI.red_background() <> " " <> IO.ANSI.reset()
          @paddle -> "_"
          @ball -> IO.ANSI.yellow() <> "⬤" <> IO.ANSI.reset()
        end
      end
      |> Enum.join()
      # hack for a bigger paddle
      |> String.replace(" _ ", "___")
      |> IO.write()

      IO.write("\n")
    end
  end

  def parse(input) do
    input |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
  end
end
