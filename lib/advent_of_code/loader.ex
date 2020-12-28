defmodule AdventOfCode.Loader do
  def load(day, name \\ "input.txt") do
    "../inputs/day_#{day}_#{name}"
    |> Path.expand(__DIR__)
    |> File.read!()
  end
end
