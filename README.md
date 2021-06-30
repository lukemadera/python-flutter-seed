# Seed App

Python (with sockets) + MongoDB + Flutter


## Setup

For (Ubuntu) script, see `server-setup.sh`

- install imagemagick - http://docs.wand-py.org/en/0.5.9/
    - Mac: `brew install imagemagick`
    - Ubuntu: `apt-get install libmagickwand-dev`
- `pip3 install -r ./requirements.txt`
- set up configs (these vary per environment and contains access keys so are NOT checked into version control)
  - `cp config.sample.yml config.yml` then edit `config.yml` as necessary.
  - `cp configloggly.sample.conf config-loggly.conf` and edit `config-loggly.conf` as needed.
  - `cp frontend/.sample-env frontend/.env` and edit `.env` as needed.
- frontend `cd frontend && flutter build web` (for frontend)
- setup config (see configuration section in `server-setup.sh`)

- make sure all Android / iOS (manifest / pList) files are update for any dependencies, e.g.
  - http (Android Internet permission)
  - file picker
  - etc (see individual dependencies for installation notes)


### Setup third party tools

Create accounts and add api keys in configs for each:
- database: mongodb - free tier on AtlasDB
- email: free tier on mailchimp or sendgrid
- logging: free tier on loggly


## Local development

- `flutter run -d chrome --web-port=PORT`
- OR for non chrome (will have to manually open browser, type in URL & reload page for updates), `flutter run -d web-server --web-port=PORT`


## Rebuilding Mobile

- update version & build in pubspec.yaml & run `flutter clean`
- iOS
  - `flutter build ios`
  - Open Runner.xcworkspace & use xCode to archive & upload the build to AppStoreConnect & submit for review
- Android
  - `flutter build appbundle`
  - Use Google Play to upload app bundle & submit for review


## Updates (should be done via CI)

`git pull origin master`
`pip3 install -r ./requirements.txt` (only necessary if updated requirements.txt)
`cd frontend && flutter build web && cd ../`
`systemctl restart systemd_web_server.service`


### Versions

- Since Android & iOS take extra time to build and be approved in the app store (and for users to update), we will always have at lease TWO different versions live at once. Thus the backend needs to always support both the current (most recent) version and (at least) 1 version back, since there is only one copy of the live backend and breaking changes will not be instantly updated on mobile, thus would break the mobile apps.
    - So, the backend will need multi (2) version support. Once a new version is released though, clean up 3+ versions behind code and force a mobile / frontend update to the current supported (2 most recent) versions.
