defmodule NervesRtcModules.RTC.Utils do
  require Logger

  def do_write(i2c, write_cmd, time) do
    day_of_week = Calendar.ISO.day_of_week(time.year, time.month, time.day)

    payload = <<
      0x02,
      to_bcd(time.second),
      to_bcd(time.minute),
      to_bcd(time.hour),
      to_bcd(time.month),
      to_bcd(day_of_week),
      to_bcd(time.month),
      to_bcd(time.year - 2000)
    >>

    Circuits.I2C.write(i2c, 81, write_cmd <> payload)
  end

  def i2c_read(i2c_pid, address, {read_cmd, read_bytes}) do
    case Circuits.I2C.write_read(i2c_pid, address, read_cmd, read_bytes) do
     {:ok, time_bytes} -> Circuits.I2C.write_read(i2c_pid, address, read_cmd, read_bytes)

        << _::size(1), second::integer-size(7),
          _::size(1), minute::integer-size(7),
          _::size(1), hour::integer-size(7),
          _::size(2), day_of_month::integer-size(6),
          _day_of_week::integer-size(8),
          _::size(3), month::integer-size(5),
            year::integer-size(8) >> = time_bytes

        %NaiveDateTime{
          calendar: Calendar.ISO,
          day: to_dec(day_of_month),
          hour: to_dec(hour),
          minute: to_dec(minute),
          month: to_dec(month),
          second: to_dec(second),
          year: to_dec(year) + 2000
        }
    {:error, _err_msg} = err ->
      err
  end

  def to_dec(bcd) do
    <<digit_1::integer-size(4), digit_2::integer-size(4)>> = <<bcd::integer-size(8)>>
    digit_1 * 10 + digit_2
  end

  def to_bcd(number) do
    div(number, 10) * 16 + rem(number, 10)
  end
end
