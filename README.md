# Upupu

[![Build Status](https://travis-ci.org/xcoo/upupu.svg?branch=master)](https://travis-ci.org/xcoo/upupu)
![Supported iOS](https://img.shields.io/badge/iOS-9.0%2B-brightgreen.svg)

Simple camera application for iOS that uploads pictures to WebDAV server or Dropbox quickly. Also available on the [AppStore](https://itunes.apple.com/app/upupu/id508401854).

![Upupu Screenshots](https://raw.githubusercontent.com/xcoo/upupu/master/Screenshots/screenshots.jpg)

## Features

* Easy and fast uploading. Only two taps!
* Now WebDAV and Dropbox supported.
* Photo size and quality are selectable.

## Prerequisites

- Xcode 9.0
- CocoaPods 1.4.0+

## Installation

### 1. Download source code

Clone this repository,

```console
$ git clone https://github.com/xcoo/upupu.git
```

or download from [here](https://github.com/xcoo/upupu/archive/master.zip) and extract it.

### 2. Install dependencies

Install dependencies using CocoaPods.

```console
$ pod install
```

Open using Xcode.

```console
$ open Upupu.xcworkspace
```

### 3. Dropbox setup (optional)

You have to register Dropbox App keys if you want to use Dropbox.
Go to [App Console](https://www.dropbox.com/developers/apps) and click "Create app."
Write your app information and specify "Full Dropbox" in Access level section.

Open "Constants.swift" and replace `YOUR_DROPBOX_APP_KEY` with your actual key.

```swift
struct Dropbox {

    static let kDBAppKey = "YOUR_DROPBOX_APP_KEY"

}
```

Click **Upupu** -> **Info** tab -> **URL Types** section on Xcode and replace **URL Schemes** in the same way.

```
URL Schemes: db-YOUR_DROPBOX_APP_KEY
```

### 4. Run

Run Upupu on iPhone or iPhone simulator.
Let's Upupu!

## License

Copyright © 2012-2017 [Xcoo, Inc.](https://xcoo.jp/)

Distributed under the [Apache License, Version 2.0](./LICENSE).
