defmodule NervesRtcModules.I2CUtils do
  alias Circuits.I2C

  def read_register(bus, device, register, count) do
    with {:ok, bus} <- I2C.open(bus) do
      with {:ok, bytes} <- I2C.write_read(bus, device, <<register>>, count),
           :ok <- I2C.close(bus) do
        {:ok, bytes}
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

  def write_register(bus, device, register, data) do
    with {:ok, bus} <- I2C.open(bus) do
      with :ok <- I2C.write(bus, device, <<register>> <> data),
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
