fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios register_app

```sh
[bundle exec] fastlane ios register_app
```

Register Bundle ID in Apple Developer Portal

### ios create_iap

```sh
[bundle exec] fastlane ios create_iap
```

Create In-App Purchase

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Capture App Store screenshots

### ios frame_screenshots

```sh
[bundle exec] fastlane ios frame_screenshots
```

Frame screenshots with device bezels and marketing text

### ios generate_screenshots

```sh
[bundle exec] fastlane ios generate_screenshots
```

Generate all screenshots with framing

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to App Store Connect (TestFlight)

### ios release

```sh
[bundle exec] fastlane ios release
```

Build and upload to App Store for review

### ios download_metadata

```sh
[bundle exec] fastlane ios download_metadata
```

Download existing metadata from App Store Connect

### ios upload_metadata

```sh
[bundle exec] fastlane ios upload_metadata
```

Upload metadata to App Store Connect

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Upload screenshots to App Store Connect

### ios upload_all

```sh
[bundle exec] fastlane ios upload_all
```

Upload everything (metadata + screenshots) to App Store Connect

### ios certs

```sh
[bundle exec] fastlane ios certs
```

Sync certificates and provisioning profiles

### ios create_certs

```sh
[bundle exec] fastlane ios create_certs
```

Create new certificates and profiles

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
