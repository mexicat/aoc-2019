defmodule AdventOfCode.Day08 do
  def part1(input) do
    winner =
      input
      |> parse()
      |> Enum.map(&Enum.frequencies/1)
      |> Enum.sort_by(&Map.get(&1, "0"))
      |> hd()

    Map.get(winner, "1") * Map.get(winner, "2")
  end

  def part2(input) do
    input
    |> parse()
    |> Enum.zip()
    |> Enum.map(fn layer ->
      layer = Tuple.to_list(layer)

      Enum.reduce_while(layer, nil, fn
        "2", _ -> {:cont, nil}
        x, _ -> {:halt, x}
      end)
    end)
    |> visualize()
  end

  def visualize(pixels) do
    pixels
    |> Enum.map(fn
      "0" -> " "
      "1" -> "#"
    end)
    |> Enum.chunk_every(25)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def parse(input) do
    input |> String.trim() |> String.codepoints() |> Enum.chunk_every(25 * 6)
  end
end
