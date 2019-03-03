defmodule Radio.D710 do
  alias Circuits.UART

  def send_command_mode_command(pid) do
    UART.write(pid, "\x03")
  end

  def enter_kiss_mode(pid) do
    # This is the sequence to put the radio into KISS mode from command mode
    UART.write(pid, "MON OFF")
    UART.write(pid, "KISS ON")
    UART.write(pid, "RESTART")
    # KISS messages are bookended by 0xC0, so lets use that to break lines
    UART.configure(pid, framing: {UART.Framing.Line, separator: "\xC0"})
  end

  def exit_kiss_mode(pid) do
    # This command is supposed to break the radio out of KISS mode
    UART.write(pid, "\xC0\xFF\xC0")
    # Command mode uses crlf to delineate the end of a line
    UART.configure(pid, framing: {UART.Framing.Line, separator: "\r\n"})
  end
end
