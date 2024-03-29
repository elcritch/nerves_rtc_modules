defmodule NervesRtcModules.RTC.Ds1307 do
  @moduledoc """
  RTC Module for DS1307 chip with NVRAM and Control register functions.
  Tested with hardware on Oct 28, 2019.
  """
  @behaviour NervesTime.HardwareTimeModule
  alias NervesRtcModules.I2CUtils
  import NervesRtcModules, only: [to_dec: 1, to_bcd: 1]

  require Logger

  @i2c_bus Application.get_env(:nerves_rtc_modules, :i2c_bus, "i2c-1")
  @i2c_address Application.get_env(:nerves_rtc_modules, :i2c_address, 0x68)

  @dt_reg 0x0
  @dt_count 7

  @ctrl_reg 0x7
  @ctrl_count 1

  @nvram_reg 0x8
  @nvram_count 56

  @impl true
  def retrieve_time() do
    with {:ok, time_bytes} <- I2CUtils.read_register(@i2c_bus,
                                                     @i2c_address,
                                                     @dt_reg,
                                                     @dt_count),
         <<_ch::size(1), second::integer-size(7),
            _::size(1), minute::integer-size(7),
            _::size(1), hour::integer-size(7),
            _day_of_week::integer-size(8),
            _::size(2), day_of_month::integer-size(6),
            _::size(3), month::integer-size(5),
            year::integer-size(8)>> = time_bytes do

      Logger.info("Retrieving time from RTC DS1307 ")
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
        :error
    end
  end

  @impl true
  @spec update_time() :: :ok | :error
  def update_time() do
    time = NaiveDateTime.utc_now()
    # day_of_week = Calendar.ISO.day_of_week(time.year, time.month, time.day)

    with payload <-
            <<to_bcd(time.second),
              to_bcd(time.minute),
              to_bcd(time.hour),
              to_bcd(0),
              to_bcd(time.day),
              to_bcd(time.month),
              to_bcd(time.year - 2000)>>,
          :ok <- I2CUtils.write_register(@i2c_bus, @i2c_address, @dt_reg, payload)
    do
      :ok
    else
      _err ->
        :error
    end
  end

  def update_control(%{out: out, sqwe: sqwe, rs1: rs1, rs0: rs0}) do
    with payload <- << out::size(1), 0x0::size(2), sqwe::size(1), 0::size(2), rs1::size(1), rs0::size(1) >>,
        :ok <- I2CUtils.write_register(@i2c_bus, @i2c_address, @ctrl_reg, payload)
    do
      :ok
    else
      _err ->
        :error
    end
  end

  def retrieve_control() do
    with {:ok, bytes} <- I2CUtils.read_register(@i2c_bus, @i2c_address, @ctrl_reg, @ctrl_count),
         << out::size(1), 0x0::size(2), sqwe::size(1), 0::size(2), rs1::size(1), rs0::size(1) >> <- bytes
    do
      %{out: out, sqwe: sqwe, rs1: rs1, rs0: rs0}
    else
      _err ->
        :error
    end
  end

  def retrieve_nvram() do
    with {:ok, bytes} <- I2CUtils.read_register(@i2c_bus, @i2c_address, @nvram_reg, @nvram_count)
    do
      bytes
    else
      _err ->
        :error
    end
  end

  def update_nvram(bytes) do
    with :ok <- I2CUtils.write_register(@i2c_bus, @i2c_address, @ctrl_reg, bytes)
    do
      :ok
    else
      _err ->
        :error
    end
  end

end
