defmodule Kiss.AX25Parser do
  use Bitwise
  require Logger

  def parse(<<dest_callsign::binary-size(6), dest_ssid::binary-size(1), rest::binary>> = packet) do
    Logger.debug("packet: #{inspect(packet, limit: :infinity)}")

    with {:ok, ssid_field} <- parse_ssid(dest_ssid),
         {:ok, destination_callsign} <- parse_callsign(dest_callsign, ssid_field),
         {:ok, result} <- parse_source_addresses(rest, []) do
      <<control::8, pid::8, rest::binary>> = result.rest

      %{
        destination_address: destination_callsign,
        dest_ssid: ssid_field.ssid,
        source_addresses: result.addresses,
        control: control,
        pid: pid,
        info_field: rest
      }
    else
      err -> err
    end
  end

  def parse(bad_packet) do
    Logger.error("Unable to parse packet #{inspect(bad_packet, limit: :infinity)}")
    {:err, :unable_to_parse_packet}
  end

  # If the ssid field ends in 1, it means we are at the end of the SSID list
  def parse_source_addresses(
        <<callsign::binary-size(6), ssid::size(8), rest::binary>>,
        acc
      )
      when band(1, ssid) == 1 do
    {:ok, ssid} = parse_ssid(<<ssid>>)
    {:ok, callsign} = parse_callsign(callsign, ssid)
    {:ok, %{addresses: acc ++ [callsign], rest: rest}}
  end

  # If the ssid field ends in 0, we have more SSIDs to parse
  def parse_source_addresses(
        <<callsign::binary-size(6), ssid::size(8), rest::binary>>,
        acc
      )
      when band(1, ssid) == 0 do
    {:ok, ssid} = parse_ssid(<<ssid>>)
    {:ok, callsign} = parse_callsign(callsign, ssid)
    # Add this callsign to the list and recurse
    parse_source_addresses(rest, acc ++ [callsign])
  end

  def parse_source_addresses(payload, _acc) do
    Logger.error("Couldn't parse source addresses: #{inspect(payload)}")
    {:err, :unable_to_parse_address}
  end

  def parse_ssid(<<h::size(1), rr::size(2), ssid::size(4), hdlc_extension::size(1)>>) do
    repeated? = if h == 1, do: true, else: false
    {:ok, %{has_been_repeated: repeated?, rr: rr, ssid: ssid, hdlc_bit: hdlc_extension}}
  end

  def safe_display(c) when c in 32..126, do: c
  def safe_display(_c), do: 63

  def parse_callsign(callsign, ssid) do
    # Callsigns are left shifted 1 bit, so undo that to get their ascii value
    callsign = for <<b::8 <- callsign>>, do: b >>> 1
    callsign = Enum.map(callsign, &safe_display/1) |> List.to_string() |> String.trim()
    repeated_indicator = if ssid.has_been_repeated, do: "*", else: ""
    # Strip superfluous zero, otherwise append SSID
    suffix = if ssid.ssid == 0, do: "", else: "-" <> Integer.to_string(ssid.ssid)
    {:ok, callsign <> repeated_indicator <> suffix}
  end
end
