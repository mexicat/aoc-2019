defmodule Mix.Tasks.Solve do
  use Mix.Task

  def run(args) do
    day = args |> Enum.at(0) |> String.pad_leading(2, "0")

    part =
      case args |> Enum.at(1) |> String.to_integer() do
        1 -> :part1
        2 -> :part2
        _ -> raise "unknown part"
      end

    input = AdventOfCode.Loader.load(day)

    if Enum.member?(args, "-b") do
      Benchee.run(%{
        part => fn -> apply(Module.concat([AdventOfCode, "Day#{day}"]), part, [input]) end
      })
    else
      apply(Module.concat([AdventOfCode, "Day#{day}"]), part, [input])
      |> IO.inspect(label: "Day #{day} #{part} results")
    end
  end
end
