# KMP-Panna iOS App
## Simple iOS app to show iOT data coming from KMP Pellet Burner

The burner comes with a web interface that for some reason Safari has struggles connecting to, returning with "connection reset by peer".
I created this simple app, my very first one, to show data in a better way, more reliably, and maybe with possibilities to add push notifications when the burner is in error state.
Feel free to contact me to contribute!

The app is very rough and i have a list of improvements that should be applied.
Also, it is not pushed to AppStore now, and it shuld be pushed to an iPhone in Develper mode

## todo list:

- Show time to next requestTimer
- Support for Night theme
- Submit to AppStore
- Support to Localization
- idea: add "log" tab where to monitor events?

## Example of Json response
See definition of KMPData in KMPUtilities.swift for interpretation of meaning
```
{
  "mode":"VILAR...",
  "glow":"AVST&#196;NGT",
  "ttop":"49",
  "tbottom":"443",
  "feed":"0",
  "xFan":"0",
  "cFan":"0",
  "tFlame":"1",
  "tFlue":"21",
  "draft":"0",
  "amps":"0.1",
  "tRoom":"16",
  "tStop":"70",
  "tStart":"45",
  "nattFlagg":"0",
  "mode2":"2",
  "alarm1":"NO ALARM",
  "alarm2":"MEDELANDE",
  "lang":"1",
  "bmpT":"21",
  "Flame":"1",
  "Hardware":"1"
}
```

## Background task
On dev mode, during a debug breakpoint, type this in the lldb debug console to simulate a bg task
```
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"bcc.KMP-Panna.backgroundTask.monitor"]
```
