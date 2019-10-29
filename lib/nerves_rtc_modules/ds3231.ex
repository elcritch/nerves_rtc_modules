defmodule NervesRtcModules.RTC.Ds3231 do
  @behaviour NervesTime.HardwareTimeModule

  alias Circuits.I2C

  require Logger

  @i2c_bus Application.get_env(:nerves_rtc_modules, :i2c_bus, nil)
  @i2c_address Application.get_env(:nerves_rtc_modules, :i2c_address, nil)

  defmodule State do
    @enforce_keys [:i2c_device, :i2c_address]
    defstruct [:i2c_device, :i2c_address, :device_pid]
  end

  @impl true
  def update_time() do
  end

  @impl true
  def retrieve_time() do

    {:ok, i2c_bus} = I2C.open(@i2c_bus)

  end

end
