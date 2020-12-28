defmodule Intcode do
  defstruct ops: [], at: 0

  def new(ops) do
    %Intcode{ops: ops, at: 0}
  end

  def run(intcode) do
    next(intcode)
  end

  # def next(intcode = %{ops: ops, at: at}) when at > length(ops), do: intcode

  def next(intcode = %{ops: ops, at: at}) do
    {past, future} = Enum.split(ops, at)
    {curr, future} = Enum.split(future, 1)

    case hd(curr) do
      1 -> add(intcode, Enum.take(future, 3)) |> next()
      2 -> multiply(intcode, Enum.take(future, 3)) |> next()
      99 -> intcode
    end
  end

  def add(intcode = %{ops: ops, at: at}, [pos1, pos2, target]) do
    ops = put_at(ops, target, get_at(ops, pos1) + get_at(ops, pos2))
    %{intcode | ops: ops, at: at + 4}
  end

  def multiply(intcode = %{ops: ops, at: at}, [pos1, pos2, target]) do
    ops = put_at(ops, target, get_at(ops, pos1) * get_at(ops, pos2))
    %{intcode | ops: ops, at: at + 4}
  end

  def get_at(ops, index) do
    Enum.at(ops, index)
  end

  def put_at(ops, index, value) do
    List.replace_at(ops, index, value)
  end
end
