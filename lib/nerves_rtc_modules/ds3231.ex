defmodule NervesRtcModules.RTC.Ds3231 do
  @moduledoc """
  Warning: Untested!
  TODO: Test and Fixme
  """
  @behaviour NervesTime.HardwareTimeModule
  alias Circuits.I2C
  import NervesRtcModules, only: [to_dec: 1, to_bcd: 1]

  require Logger

  @i2c_bus Application.get_env(:nerves_rtc_modules, :i2c_bus, "i2c-1")
  @i2c_address Application.get_env(:nerves_rtc_modules, :i2c_address, 0x68)

  @i2c_read_cmd <<0x02>>
  @i2c_read_len 7

  @i2c_write_reg 0x00
  # @ds1307_control 0x07
  # @ds1307_nvm_ram 0x08

  @impl true
  def retrieve_time() do
    with {:ok, bus} <- I2C.open(@i2c_bus) do
      with {:ok, time_bytes} <- I2C.write_read(bus, @i2c_address, @i2c_read_cmd, @i2c_read_len),
           <<_clock_control_bit::size(1), second::integer-size(7), _::size(1),
             minute::integer-size(7), _::size(1), hour::integer-size(7), _::size(2),
             day_of_month::integer-size(6), _day_of_week::integer-size(8), _::size(3),
             month::integer-size(5), year::integer-size(8)>> = time_bytes,
           :ok <- I2C.close(bus) do
        %NaiveDateTime{
          calendar: Calendar.ISO,
          day: to_dec(day_of_month),
          hour: to_dec(hour),
          minute: to_dec(minute),
          month: to_dec(month),
          second: to_dec(second),
          year: to_dec(year) + 2000
        }
      else
        _err ->
          I2C.close(bus)
          :error
      end
    else
      _err ->
        :error
    end
  end

  @impl true
  @spec update_time() :: :ok | :error
  def update_time() do
    time = NaiveDateTime.utc_now()
    day_of_week = Calendar.ISO.day_of_week(time.year, time.month, time.day)

    with {:ok, bus} <- I2C.open(@i2c_bus) do
      with payload <-
             <<@i2c_write_reg, to_bcd(time.second), to_bcd(time.minute), to_bcd(time.hour),
               to_bcd(time.month), to_bcd(day_of_week), to_bcd(time.month),
               to_bcd(time.year - 2000)>>,
           :ok <- I2C.write(bus, @i2c_address, payload),
           :ok <- I2C.close(bus) do
        :ok
      else
        _err ->
          I2C.close(bus)
          :error
      end
    else
      _err ->
        :error
    end
  end
end
