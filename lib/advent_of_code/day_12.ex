defmodule AdventOfCode.Day12 do
  def part1(input) do
    input
    |> parse()
    |> Enum.map(&init_vel/1)
    |> simulate_motion(1000)
    |> Enum.map(&calc_energy/1)
    |> Enum.sum()
  end

  def part2(input) do
    %{x: x, y: y, z: z} = input
    |> parse()
    |> Enum.map(&init_vel/1)
    |> find_repeating()

    x |> lcm(y) |> lcm(z)
  end

  def init_vel(pos) do
    %{pos: pos, vel: %{x: 0, y: 0, z: 0}}
  end

  def simulate_motion(moons, 0), do: moons

  def simulate_motion(moons, steps) do
    moons
    |> Enum.map(&apply_gravity(&1, moons))
    |> Enum.map(&apply_velocity/1)
    |> simulate_motion(steps - 1)
  end

  def apply_gravity(moon, moons) do
    vel = %{
      x: calc_new_velocity(moon, :x, moons),
      y: calc_new_velocity(moon, :y, moons),
      z: calc_new_velocity(moon, :z, moons)
    }

    %{moon | vel: vel}
  end

  def apply_velocity(%{pos: pos, vel: vel}) do
    pos = %{x: pos.x + vel.x, y: pos.y + vel.y, z: pos.z + vel.z}
    %{pos: pos, vel: vel}
  end

  def calc_new_velocity(moon, key, moons) do
    Map.get(moon.vel, key) +
      Enum.count(moons, &(Map.get(&1.pos, key) > Map.get(moon.pos, key))) -
      Enum.count(moons, &(Map.get(&1.pos, key) < Map.get(moon.pos, key)))
  end

  def calc_energy(%{pos: pos, vel: vel}) do
    (abs(pos.x) + abs(pos.y) + abs(pos.z)) * (abs(vel.x) + abs(vel.y) + abs(vel.z))
  end

  def find_repeating(moons) do
    moons
    |> Stream.iterate(&simulate_motion(&1, 1))
    |> Enum.reduce_while(%{x: MapSet.new(), y: MapSet.new(), z: MapSet.new()}, fn moons, acc ->
      acc =
        acc
        |> Enum.map(fn
          {axis, n} when is_integer(n) ->
            {axis, n}

          {axis, set} ->
            points = Enum.map(moons, fn m -> {Map.get(m.pos, axis), Map.get(m.vel, axis)} end)

            case points in set do
              true -> {axis, MapSet.size(set)}
              false -> {axis, MapSet.put(set, points)}
            end
        end)
        |> Map.new()

      case is_integer(acc.x) && is_integer(acc.y) && is_integer(acc.z) do
        false -> {:cont, acc}
        true -> {:halt, acc}
      end
    end)
  end

  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(0, 0), do: 0
  def lcm(a, b), do: div(a * b, gcd(a, b))

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, x, _, y, _, z] =
        line |> String.trim_leading("<") |> String.trim_trailing(">") |> String.split(["=", ", "])

      %{x: String.to_integer(x), y: String.to_integer(y), z: String.to_integer(z)}
    end)
  end
end
