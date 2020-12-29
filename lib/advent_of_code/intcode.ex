defmodule Intcode do
  defstruct ops: [], at: 0, input: nil, output: [], phase: nil

  @add 1
  @multiply 2
  @input 3
  @output 4
  @jump_if_true 5
  @jump_if_false 6
  @less_than 7
  @equals 8
  @halt 99

  @position 0
  @immediate 1

  def new(ops, input \\ nil, phase \\ nil) do
    %Intcode{ops: ops, at: 0, input: input, phase: phase}
  end

  def set_input(intcode, input) do
    %{intcode | input: input}
  end

  def run(intcode) do
    Stream.iterate({:cont, intcode}, fn
      {:out, intcode} ->
        next(intcode)

      {:cont, intcode} ->
        next(intcode)

      {:halt, intcode} ->
        # IO.inspect(intcode)
        {:halt, intcode}
    end)
    |> Enum.find(&(elem(&1, 0) == :halt))
    |> elem(1)
  end

  def run_until_output(intcode) do
    Stream.iterate({:cont, intcode}, fn
      {:out, intcode} ->
        {:out, intcode}

      {:cont, intcode} ->
        next(intcode)

      {:halt, intcode} ->
        {:halt, intcode}
    end)
  end

  def next(intcode = %{ops: ops, at: at}) do
    {operation, modes} = ops |> Enum.at(at) |> parse_op_and_mode()
    intcode |> op(operation, modes)
  end

  # ADD
  def op(intcode = %{ops: ops, at: at}, @add, [m1, m2]) do
    result = get_param(ops, at + 1, m1) + get_param(ops, at + 2, m2)
    ops = set_param(ops, at + 3, result)
    {:cont, %{intcode | ops: ops, at: at + 4}}
  end

  # MULTIPLY
  def op(intcode = %{ops: ops, at: at}, @multiply, [m1, m2]) do
    result = get_param(ops, at + 1, m1) * get_param(ops, at + 2, m2)
    ops = set_param(ops, at + 3, result)
    {:cont, %{intcode | ops: ops, at: at + 4}}
  end

  # INPUT
  def op(intcode = %{ops: ops, at: at, input: input, phase: phase}, @input, _) do
    i = get_param(ops, at + 1, @immediate)

    case phase do
      nil ->
        ops = List.replace_at(ops, i, input)
        {:cont, %{intcode | ops: ops, at: at + 2}}

      n ->
        ops = List.replace_at(ops, i, n)
        {:cont, %{intcode | ops: ops, phase: nil, at: at + 2}}
    end
  end

  # OUTPUT
  def op(intcode = %{ops: ops, at: at, output: output}, @output, _) do
    res = get_param(ops, at + 1)
    output = [res | output]
    {:out, %{intcode | output: output, at: at + 2}}
  end

  # JUMP IF TRUE
  def op(intcode = %{ops: ops, at: at}, @jump_if_true, [m1, m2]) do
    new_at =
      case get_param(ops, at + 1, m1) do
        0 -> at + 3
        _ -> get_param(ops, at + 2, m2)
      end

    {:cont, %{intcode | at: new_at}}
  end

  # JUMP IF FALSE
  def op(intcode = %{ops: ops, at: at}, @jump_if_false, [m1, m2]) do
    new_at =
      case get_param(ops, at + 1, m1) do
        0 -> get_param(ops, at + 2, m2)
        _ -> at + 3
      end

    {:cont, %{intcode | at: new_at}}
  end

  # LESS THAN
  def op(intcode = %{ops: ops, at: at}, @less_than, [m1, m2]) do
    ops =
      case get_param(ops, at + 1, m1) < get_param(ops, at + 2, m2) do
        true -> set_param(ops, at + 3, 1)
        false -> set_param(ops, at + 3, 0)
      end

    {:cont, %{intcode | ops: ops, at: at + 4}}
  end

  # EQUALS
  def op(intcode = %{ops: ops, at: at}, @equals, [m1, m2]) do
    ops =
      case get_param(ops, at + 1, m1) == get_param(ops, at + 2, m2) do
        true -> set_param(ops, at + 3, 1)
        false -> set_param(ops, at + 3, 0)
      end

    {:cont, %{intcode | ops: ops, at: at + 4}}
  end

  # HALT
  def op(intcode, @halt, _) do
    {:halt, intcode}
  end

  def parse_op_and_mode(instruction) do
    digits = Integer.digits(instruction)
    op = Enum.at(digits, -2, 0) * 10 + Enum.at(digits, -1)
    modes = [Enum.at(digits, -3, 0), Enum.at(digits, -4, 0)]
    {op, modes}
  end

  # shortcut
  def get_param(ops, index), do: get_param(ops, index, @position)

  def get_param(ops, index, @position) do
    i = Enum.at(ops, index)
    Enum.at(ops, i)
  end

  def get_param(ops, index, @immediate) do
    Enum.at(ops, index)
  end

  def set_param(ops, index, value) do
    i = Enum.at(ops, index)
    List.replace_at(ops, i, value)
  end
end
