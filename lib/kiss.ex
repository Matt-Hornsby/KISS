defmodule Kiss do
  alias Circuits.UART
  use Bitwise
  use GenServer
  require Logger

  def init(_args) do
    # Trap exits so we can gracefully shut down
    Process.flag(:trap_exit, true)
    uart_pid = connect_to_radio()

    {:ok, uart_pid}
  end

  def handle_call(:disconnect, _from, state) do
    Logger.debug("Disconnecting from device")
    UART.close(state)
    {:stop, "Disconnected", nil}
  end

  def handle_info({:circuits_uart, _device, ""}, state) do
    {:noreply, state}
  end

  def handle_info({:circuits_uart, _device, message}, state) do
    display(message)
    {:noreply, state}
  end

  def terminate(reason, state) do
    # Do Shutdown Stuff
    Logger.debug("Disconnecting from device")
    UART.close(state)

    :normal
  end

  defp connect_to_radio do
    {:ok, pid} = UART.start_link()
    device_path = Application.get_env(:kiss, :port, "/dev/cu.usbserial")
    device_speed = Application.get_env(:kiss, :baud, 9600)
    Logger.info("Connecting to #{inspect(device_path)} at #{inspect(device_speed)} baud")
    UART.open(pid, device_path, speed: device_speed)
    UART.configure(pid, framing: {UART.Framing.Line, separator: "\xC0"})
    pid
  end

  defp display(""), do: nil

  defp display(<<0, kiss_data::binary>>) do
    IO.puts(String.duplicate("-", 70))
    Kiss.AX25Parser.parse(kiss_data) |> IO.inspect()
  end

  defp display(_whatever), do: "UNKNOWN FORMAT"

  # Client API

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def stop(pid) do
    GenServer.stop(pid)
  end
end
