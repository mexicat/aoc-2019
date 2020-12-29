defmodule AdventOfCode.Day07 do
  def part1(input) do
    ops = parse(input)

    combinations(0..4)
    |> Enum.map(&run_with_phases(ops, &1))
    |> Enum.max()
  end

  def part2(input) do
    ops = parse(input)

    combinations(5..9)
    |> Enum.map(&run_loop(ops, &1))
    |> Enum.max()
  end

  def run_with_phases(ops, phases) do
    Enum.reduce(phases, 0, fn phase, acc ->
      Intcode.new(ops, acc, phase)
      |> Intcode.run()
      |> Map.get(:output)
      |> hd()
    end)
  end

  def run_loop(ops, phases) do
    amps = Enum.map(phases, fn phase -> Intcode.new(ops, 0, phase) end)

    Enum.reduce_while(Stream.cycle(0..4), {0, amps}, fn i, {acc, amps} ->
      amp = Enum.at(amps, i)
      {result, new_amp} = amp |> Intcode.set_input(acc) |> Intcode.run_until_output()

      case result do
        :out ->
          new_acc = new_amp |> Map.get(:output) |> hd()
          new_amps = List.replace_at(amps, i, new_amp)
          {:cont, {new_acc, new_amps}}

        :halt ->
          {:halt, acc}
      end
    end)
  end

  def combinations(range) do
    for a <- range,
        b <- range,
        c <- range,
        d <- range,
        e <- range,
        combs = [a, b, c, d, e],
        combs |> Enum.uniq() |> length() == 5 do
      combs
    end
  end

  def parse(input) do
    input |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
  end
end
