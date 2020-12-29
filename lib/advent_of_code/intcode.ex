defmodule Intcode do
  defstruct ops: %{}, at: 0, input: nil, output: [], phase: nil, rel_base: 0

  @add 1
  @multiply 2
  @input 3
  @output 4
  @jump_if_true 5
  @jump_if_false 6
  @less_than 7
  @equals 8
  @relative_base_offset 9
  @halt 99

  @position 0
  @immediate 1
  @relative 2

  def new(ops, input \\ nil, phase \\ nil) do
    ops = ops |> Enum.with_index() |> Enum.map(fn {k, v} -> {v, k} end) |> Map.new()
    %Intcode{ops: ops, at: 0, input: input, phase: phase}
  end

  def set_input(intcode, input) do
    %{intcode | input: input}
  end

  def run(intcode) do
    case next(intcode) do
      {:cont, intcode} -> run(intcode)
      {:out, intcode} -> run(intcode)
      {:halt, intcode} -> intcode
    end
  end

  def run_until_output(intcode) do
    case next(intcode) do
      {:cont, intcode} -> run_until_output(intcode)
      {:out, intcode} -> {:out, intcode}
      {:halt, intcode} -> {:halt, intcode}
    end
  end

  def next(intcode = %{ops: ops, at: at}) do
    {operation, modes} = ops |> Map.get(at) |> parse_op_and_mode()
    # IO.inspect({intcode.at, {operation, modes}, intcode.input, intcode.output, intcode.rel_base})
    op(intcode, operation, modes)
  end

  # ADD
  def op(intcode = %{at: at}, @add, [m1, m2, m3]) do
    result = get_param(intcode, at + 1, m1) + get_param(intcode, at + 2, m2)
    ops = set_param(intcode, at + 3, result, m3)

    {:cont, %{intcode | ops: ops, at: at + 4}}
  end

  # MULTIPLY
  def op(intcode = %{at: at}, @multiply, [m1, m2, m3]) do
    result = get_param(intcode, at + 1, m1) * get_param(intcode, at + 2, m2)
    ops = set_param(intcode, at + 3, result, m3)

    {:cont, %{intcode | ops: ops, at: at + 4}}
  end

  # INPUT
  def op(intcode = %{at: at, input: input, phase: phase}, @input, [m1, _, _]) do
    case phase do
      nil ->
        ops = set_param(intcode, at + 1, input, m1)
        {:cont, %{intcode | ops: ops, at: at + 2}}

      n ->
        ops = set_param(intcode, at + 1, n, m1)
        {:cont, %{intcode | ops: ops, phase: nil, at: at + 2}}
    end
  end

  # OUTPUT
  def op(intcode = %{at: at, output: output}, @output, [m1, _, _]) do
    res = get_param(intcode, at + 1, m1)
    output = [res | output]

    {:out, %{intcode | output: output, at: at + 2}}
  end

  # JUMP IF TRUE
  def op(intcode = %{at: at}, @jump_if_true, [m1, m2, _]) do
    new_at =
      case get_param(intcode, at + 1, m1) do
        0 -> at + 3
        _ -> get_param(intcode, at + 2, m2)
      end

    {:cont, %{intcode | at: new_at}}
  end

  # JUMP IF FALSE
  def op(intcode = %{at: at}, @jump_if_false, [m1, m2, _]) do
    new_at =
      case get_param(intcode, at + 1, m1) do
        0 -> get_param(intcode, at + 2, m2)
        _ -> at + 3
      end

    {:cont, %{intcode | at: new_at}}
  end

  # LESS THAN
  def op(intcode = %{at: at}, @less_than, [m1, m2, m3]) do
    ops =
      case get_param(intcode, at + 1, m1) < get_param(intcode, at + 2, m2) do
        true -> set_param(intcode, at + 3, 1, m3)
        false -> set_param(intcode, at + 3, 0, m3)
      end

    {:cont, %{intcode | ops: ops, at: at + 4}}
  end

  # EQUALS
  def op(intcode = %{at: at}, @equals, [m1, m2, m3]) do
    ops =
      case get_param(intcode, at + 1, m1) == get_param(intcode, at + 2, m2) do
        true -> set_param(intcode, at + 3, 1, m3)
        false -> set_param(intcode, at + 3, 0, m3)
      end

    {:cont, %{intcode | ops: ops, at: at + 4}}
  end

  # REL_BASE_OFFSET
  def op(intcode = %{at: at, rel_base: rel_base}, @relative_base_offset, [m1, _, _]) do
    rel_base = rel_base + get_param(intcode, at + 1, m1)

    {:cont, %{intcode | rel_base: rel_base, at: at + 2}}
  end

  # HALT
  def op(intcode, @halt, _) do
    {:halt, intcode}
  end

  def parse_op_and_mode(instruction) do
    digits = Integer.digits(instruction)
    op = Enum.at(digits, -2, 0) * 10 + Enum.at(digits, -1)
    modes = [Enum.at(digits, -3, 0), Enum.at(digits, -4, 0), Enum.at(digits, -5, 0)]
    {op, modes}
  end

  # shortcut
  def get_param(intcode, index), do: get_param(intcode, index, @position)

  def get_param(intcode, index, @position) do
    i = Map.get(intcode.ops, index, 0)
    Map.get(intcode.ops, i, 0)
  end

  def get_param(intcode, index, @immediate) do
    Map.get(intcode.ops, index, 0)
  end

  def get_param(intcode, index, @relative) do
    i = Map.get(intcode.ops, index, 0)
    Map.get(intcode.ops, i + intcode.rel_base, 0)
  end

  # shortcut
  def set_param(intcode, index, value), do: set_param(intcode, index, value, @position)

  def set_param(intcode, index, value, @position) do
    i = Map.get(intcode.ops, index)
    Map.put(intcode.ops, i, value)
  end

  # do we need @immediate for set too? (so far, no)

  def set_param(intcode, index, value, @relative) do
    i = Map.get(intcode.ops, index)
    Map.put(intcode.ops, i + intcode.rel_base, value)
  end
end
