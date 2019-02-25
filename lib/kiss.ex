defmodule Kiss do
  alias Circuits.UART
  use Bitwise

  def connect_to_radio do
    {:ok, pid} = UART.start_link()
    UART.open(pid, "/dev/cu.usbserial", speed: 9600, active: true)
    UART.configure(pid, framing: {UART.Framing.Line, separator: "\xC0"})
    pid
  end

  def send_command_mode_command(pid) do
    Circuits.UART.write(pid, "\x03")
  end

  def enter_kiss_mode(pid) do
    Circuits.UART.write(pid, "MON OFF")
    Circuits.UART.write(pid, "KISS ON")
    Circuits.UART.write(pid, "RESTART")
    Circuits.UART.configure(pid, framing: {Circuits.UART.Framing.Line, separator: "\xC0"})
  end

  def exit_kiss_mode(pid) do
    Circuits.UART.write(pid, "\xC0\xFF\xC0")
    UART.configure(pid, framing: {UART.Framing.Line, separator: "\r\n"})
  end

  def listen() do
    receive do
      {:circuits_uart, _device, data} -> display(data)
    end

    listen()
  end

  def display(""), do: nil

  def display(<<0, kiss_data::binary>>) do
    IO.puts(String.duplicate("-", 70))
    Kiss.AX25Parser.parse(kiss_data) |> IO.inspect()
  end

  def display(_whatever) do
    "UNKNOWN FORMAT"
  end
end
