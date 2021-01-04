defmodule AdventOfCode.Day14 do
  defmodule Factory do
    def start() do
      {:ok, pid} = Agent.start_link(fn -> %{} end)
      pid
    end

    def stop(pid), do: Agent.stop(pid)

    def get(pid, chem), do: Agent.get(pid, &Map.get(&1, chem, 0))
    def put(pid, chem, n), do: Agent.update(pid, &Map.put(&1, chem, n))
  end

  def part1(input) do
    mappings = parse(input)
    factory = Factory.start()
    res = make_chemical(1, "FUEL", mappings, factory)
    Factory.stop(factory)
    res
  end

  def part2(input) do
    mappings = parse(input)
    factory = Factory.start()
    res = find_fuel(mappings, factory, 1, 0, 1_000_000_000_000, 1_000_000_000_000)
    Factory.stop(factory)
    res
  end

  def make_chemical(amt, chemical, mappings, deposit, ores \\ 0) do
    case Factory.get(deposit, chemical) do
      n when n > amt ->
        Factory.put(deposit, chemical, n - amt)
        ores

      n ->
        needed = amt - n
        {min, ingredients} = Map.get(mappings, chemical)
        to_create = ceil(needed / min) * min
        repeats = ceil(needed / min)
        ingredients = Enum.map(ingredients, fn {c, a} -> {c, a * repeats} end)
        Factory.put(deposit, chemical, to_create - needed)

        Enum.reduce(ingredients, ores, fn
          {"ORE", a}, ores -> ores + a
          {c, a}, ores -> make_chemical(a, c, mappings, deposit, ores)
        end)
    end
  end

  def find_fuel(mappings, factory, n, low, high, ore) do
    needs = make_chemical(n, "FUEL", mappings, factory)

    cond do
      high - low <= 1 ->
        low

      needs < ore ->
        low = n
        n = n + div(high - low, 2)
        find_fuel(mappings, factory, n, low, high, ore)

      needs > ore ->
        high = n
        n = n - div(high - low, 2)
        find_fuel(mappings, factory, n, low, high, ore)
    end
  end

  def parse(input) do
    input |> String.split("\n", trim: true) |> Enum.map(&parse_line/1) |> Map.new()
  end

  def parse_line(line) do
    [{to_chem, to_amt} | from] =
      line
      |> String.split(~r/,\s|\s=>\s/)
      |> Enum.map(fn v ->
        [n, element] = String.split(v)
        {element, String.to_integer(n)}
      end)
      |> Enum.reverse()

    {to_chem, {to_amt, from}}
  end
end
