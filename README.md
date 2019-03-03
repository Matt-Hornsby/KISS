# Kiss TNC AX.25 Interface

Interact with any KISS TNC and decode ax.25 messages.

Currently this is a very immature implementation of what I hope will become a modernized set of packet radio tools for amateur radio. For now, treat this code as experimental as it's certainly not up to any quality standards at the moment.

This code has been tested with a Kenwood TM-D710 connected via a usb-to-serial cable on a macbook, and a Kenwood TH-D74 via bluetooth, so it should work with any connected TNC in KISS mode.

The TM-D710 has to be placed into KISS mode via the following commands (when connected to the full-fledged internal TNC):

```bash
KISS ON
MON OFF
RESTART
```

At this point, it should be in KISS mode. Power cycle or change TNC modes to restore normal TNC functionality.

Once in KISS mode, you can connect to the interface and start listening to packets with:

```elixir
{:ok, pid} = Kiss.start_link
```

If all works, you should start seeing decoded messages appear in your terminal. To disconnect, stop the genserver with:

```elixir
Kiss.stop(pid)
```