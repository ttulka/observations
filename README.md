# Student Observations App

<img src="logo.png" style="height: 6rem; float: right;" align="right">

Free and open-source software for school teachers to write and maintain student observations. 

Documents stored only _locally_ - no piece of data will ever leave your laptop!

Desktop application for **Windows**, **macOS**, and Linux (unofficial support).

### Features

- Compose and edit student observations 
- Manage categories of observations with predefined templates 
- Group students into classes
- Rich text editor
- Printing 
- Autosave

### Languages 
- English 
- German (Deutsch)

This software is free to use but you are welcome to <a href="https://www.buymeacoffee.com/ttulka" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 35px !important;" ></a>

## Overview

Tbd

See the [Wiki](https://github.com/ttulka/observations/wiki) pages for more details.

## Platform support

### Officially supported:

- **Windows** (tested on Win 7 and Win 10)
- **macOS** (tested on Big Sur 11.5)

### Unofficially supported:

- **Linux** (tested on Ubuntu 20.04)

The main reason to support Linux unofficially is the variety of distribution. We can't really ensure to run everywhere but we try hard.

Please [contact us](https://github.com/ttulka/observations/issues) when facing any issues - your feedback is highly valuable!


## Installation

> _**Disclaimer:**_ ​​As there is no commercial company behind this you need to accept the software as unverified when running for the first time. We're sorry for this inconvenience!

Follow the installation instructions for your platform:

### On Windows 

Tbd

### On Mac

1. [Download the installer package](https://github.com/ttulka/observations/releases/download/alpha-0.1.1/StudentObservations-Installer-macos-alpha-0.1.1.dmg)
2. Open the installer and move the app into the Applications
3. Run the app from the Applications

### On Linux (Ubuntu)

1. [Download the archive](https://github.com/ttulka/observations/releases/download/alpha-0.0.0/observations-linux-alpha-0.1.1.zip)
2. Unpack it into any directory
3. Open the directory and run the `observations` executable

#### Prerequisites:

```sh
# make sure that the sqlite3 lib is present in your system:
sudo apt-get -y install libsqlite3-0
```

## Contributions and development 

Contributions and translations are very welcome! Please make sure your change works on all supported platforms.

### Tech stack
- Flutter
- Sqlite


### To do
- searching (filtering) students
- disaster recovery
- sentiment of observation (???)

## License 

[MIT](https://github.com/ttulka/observations/blob/main/LICENSE)