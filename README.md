# Upupu

Simple camera application that backups pictures on WebDAV server.

![Upupu Screenshots](https://raw.githubusercontent.com/xcoo/upupu/master/Screenshots/screenshots.jpg)

## Prerequisites

- Xcode 7
- CocoaPods

## Usage

### 1. Download source code

    $ git clone https://github.com/xcoo/upupu.git

or download from [here](https://github.com/xcoo/upupu/archive/master.zip) and extract it.

### 2. Install dependencies

    $ pod install

Open **Upupu.xcworkspace** with Xcode.

### 3. Use Dropbox

You have to register Dropbox App keys if you want to use Dropbox.
Go to [Dropbox Developers page](https://www.dropbox.com/developers/apps) and click "Create an app."
Write your app information and specify "Full Dropbox" in Access level section.

Next, you need to change source code.

Modify Constants.swift.

```swift
struct Dropbox {

    static let kDBAppKey = "YOUR_DROPBOX_APP_KEY"

}
```

Click Upupu -> info -> URL Types on Xcode and modify URL Scheme.

    URL Schemes: db-YOUR_DROPBOX_APP_KEY

### 4. Run

Run Upupu on iPhone or iPhone simulator.
Let's Upupu!

## License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
