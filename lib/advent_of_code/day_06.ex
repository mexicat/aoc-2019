defmodule AdventOfCode.Day06 do
  def part1(input) do
    input
    |> parse()
    |> make_graph()
    |> total_orbits()
  end

  def part2(input) do
    orbits = parse(input)
    graph = make_graph(orbits)
    find_distance(graph, orbits, "SAN", "YOU")
  end

  def make_graph(orbits) do
    vertices = orbits |> List.flatten() |> MapSet.new()
    graph = :digraph.new()

    Enum.each(vertices, &:digraph.add_vertex(graph, &1))
    Enum.each(orbits, fn [from, to] -> :digraph.add_edge(graph, from, to) end)

    graph
  end

  def total_orbits(graph) do
    graph
    |> :digraph.vertices()
    |> Enum.map(&calc_orbits(graph, &1, 0))
    |> Enum.sum()
  end

  def calc_orbits(graph, orbit, acc) do
    graph
    |> :digraph.out_neighbours(orbit)
    |> Enum.map(&calc_orbits(graph, &1, 1))
    |> Enum.sum()
    |> Kernel.+(acc)
  end

  def find_distance(graph, orbits, orbit1, orbit2) do
    make_undirected(graph, orbits)
    obj1 = graph |> :digraph.out_neighbours(orbit1) |> List.first()
    obj2 = graph |> :digraph.out_neighbours(orbit2) |> List.first()

    graph
    |> :digraph.get_short_path(obj1, obj2)
    |> Enum.count()
    |> Kernel.-(1)
  end

  def make_undirected(graph, orbits) do
    Enum.each(orbits, fn [from, to] -> :digraph.add_edge(graph, to, from) end)
    graph
  end

  def parse(input) do
    input |> String.split("\n", trim: true) |> Enum.map(&String.split(&1, ")"))
  end
end
