# 🍷 Treat Yourself ~

> A Garmin watch widget to help you manage your caloric intake. 🍷

![screenshot](res/banner.png)

Treat Yourself is a lightweight Garmin watch widget designed to help you manage your daily caloric intake effectively.
By tracking your physical activity and providing personalized valuations. Treat Yourself gives you quick insights into your calorie consumption and expenditure.

> It also gives you a daily treat based on your activity level!

Get yourself the app at the [Connect IQ Store](https://apps.garmin.com/apps/31d07127-3b03-4ff4-bea9-15d297efeacf).

## Features

- **Personalized Caloric Valuation**: Calculates your daily caloric needs based on your age, weight, height, activity level
- **Activity Tracking**: Monitors your daily steps and active minutes to adjust your caloric needs dynamically
- **Daily Treat Suggestions**: Provides a daily treat suggestion based on your activity level
- **Dynamic Input Field**: Allows you to input your deficit target and the target calories for your treat
- **Estimated calorie Burn**: Estimates calories at the very end of the day based on your activity level

It's **free** and will always be, I'd be glad to hear your feedback and feature requests!

## Tested Devices

- Venu 2
- Venu 2 Plus
- Venu 2s

## Supported Devices

More than 80 devices are supported, including:

- Venu 2 series
- Venu 3 series
- Fenix 7 series
- Epix 2 series

Check out the [manifest.xml](manifest.xml) file for the full list of supported devices.

## Requirements

- Install the [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/overview/)
- Install the Monkey C extension for Visual Studio Code
- A Garmin device that supports Connect IQ apps

## Build the IQ file

```sh
$ monkeyc -o out/TreatYourself.iq -f monkey.jungle -d venu2s --release -y /Users/$USER/Documents/developer_key -e
```
