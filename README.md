# Kiss TNC AX.25 Interface

Interact with any KISS TNC and decode ax.25 messages.

Currently this is a very immature implementation of what I hope will become a modernized set of packet radio tools for amateur radio. For now, treat this code as experimental as it's certainly not up to any quality standards at the moment.

I have only tested it with a Kenwood TM-D710 so far, connected via a usb-to-serial cable on a macbook, but it should work with any connected TNC in KISS mode.

The TM-D710 has to be placed into KISS mode via the following commands (when connected to the full-fledged internal TNC):

```bash
KISS ON
MON OFF
RESTART
```

At this point, it should be in KISS mode. Power cycle or change TNC modes to restore normal TNC functionality.

Once in KISS mode, you can connect to the interface and start listening to packets with:

```elixir
Kiss.connect_to_radio
Kiss.listen
```