defmodule NervesRtcModules.RTC.Ds3231 do
  @behaviour NervesTime.HardwareTimeModule
  alias NervesRtcModules.I2CUtils
  alias Circuits.I2C

  require Logger

  @i2c_bus Application.get_env(:nerves_rtc_modules, :i2c_bus, "i2c-1")
  @i2c_address Application.get_env(:nerves_rtc_modules, :i2c_address, 81)

  @i2c_read_cmd {<<0x02>>, 7}
  @i2c_write_cmd <<>>

  @impl true
  def retrieve_time() do

    {:ok, bus} = I2C.open(@i2c_bus)

    dt = case I2CUtils.i2c_read(bus, @i2c_address, @i2c_read_cmd) do
      {:error, err_msg} ->
        Logger.warn("Error reading I2C RTC module: #{inspect err_msg}")

        :error
      dt ->
        dt
    end

    I2C.close(bus)

    dt
  end

  @impl true
  @spec update_time() :: :ok | :error
  def update_time() do
    {:ok, bus} = I2C.open(@i2c_bus)

    now = NaiveDateTime.utc_now()
    result = I2CUtils.i2c_write(bus, @i2c_address, @i2c_write_cmd, now)

    I2C.close(bus)

    result
  end

end
