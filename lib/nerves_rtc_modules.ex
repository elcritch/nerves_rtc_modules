defmodule NervesRtcModules do
  @moduledoc """
  Documentation for NervesRtcModules.
  """

  def to_dec(bcd) do
    <<digit_1::integer-size(4), digit_2::integer-size(4)>> = <<bcd::integer-size(8)>>
    digit_1 * 10 + digit_2
  end

  def to_bcd(number) do
    div(number, 10) * 16 + rem(number, 10)
  end
end
