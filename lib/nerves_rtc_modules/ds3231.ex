defmodule NervesRtcModules.RTC.Ds3231 do
  @behaviour NervesTime.HardwareTimeModule
  import NervesRtcModules.I2CUtils
  alias Circuits.I2C

  require Logger

  @i2c_bus Application.get_env(:nerves_rtc_modules, :i2c_bus, "i2c-1")
  @i2c_address Application.get_env(:nerves_rtc_modules, :i2c_address, 81)

  @i2c_read_cmd {<<0x02>>, 7}

  @impl true
  def retrieve_time() do

    {:ok, bus} = I2C.open(@i2c_bus)

    dt = case NervesRtcModules.RTC.Utils.i2c_read(bus, @i2c_address, @i2c_read_cmd) do
      {:ok, dt} -> dt
      _err -> :error
    end

    I2C.close(i2c_bus)

    dt
  end

  @impl true
  def update_time() do
    {:ok, bus} = I2C.open(@i2c_bus)

    result = NervesRtcModules.RTC.Utils.i2c_read(bus, @i2c_address, @i2c_read_cmd)

    I2C.close(i2c_bus)

    result
  end

end
