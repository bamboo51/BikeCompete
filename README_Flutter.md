# BikeCompete

BikeCompete is a Flutter app for the KOSEN Global Camp Hackathon 2026. It is a carbon-neutral cycling challenge app that combines ride tasks, GPS/sensor tracking, route maps, leaderboards, and impact stats.

## Project Members

- [Iurii](https://github.com/Qumetri)
- [Pai](https://github.com/bamboo51)
- [Komatsu](https://github.com/s2201125-sys/)
- Mahiro
- [Sou](https://github.com/J2523-Sou)

## Current Features

- Material 3 eco-themed UI.
- Ride dashboard with weekly distance progress, points, CO2 saved, GPS test, and live sensor sheet.
- Task cards that open a map page.
- Task map page with:
  - start marker at Sendai Station
  - stop marker at Ayashi Station
  - current GPS location marker when permission/location is available
  - real map tiles from CARTO's OpenStreetMap-based Voyager tiles
  - route polyline loaded from OSRM
  - fallback straight-line route if OSRM cannot load
- Worker and department leaderboard screens.
- Impact profile screen backed by the account API.
- Dummy account fallback with a visible `Dummy` tag when `/account` fails.
- Typed API client and Dart models matching `api.yaml`.
- Google sign-in service scaffold with JWT persistence.

## Project Structure

```text
lib/
  main.dart                         App theme and entry point
  navigation/                       Material 3 bottom navigation
  pages/
    home_page.dart                  Ride dashboard, task cards, task map page
    leaderboard_page.dart           Worker and department ranking UI
    account_page.dart               Impact profile with dummy fallback
  models/                           OpenAPI-shaped Dart models
  services/
    api/                            Typed API clients
    auth_service.dart               Google sign-in/JWT persistence
    gps_accelerometer_gyro.dart     GPS, accelerometer, gyroscope stream
  widgets/                          Shared UI widgets
api.yaml                            OpenAPI specification for the dummy backend
```

## Requirements

- Flutter SDK
- Dart SDK compatible with `pubspec.yaml`
- A local backend that implements `api.yaml`
- Network access for map tiles and OSRM route loading
- Location permission for GPS/current-location features

Install dependencies:

```sh
flutter pub get
```

## Main Dependencies

- `http` for API and OSRM route requests
- `geolocator` for GPS/current location
- `sensors_plus` for accelerometer and gyroscope readings
- `flutter_map` for map rendering
- `latlong2` for map coordinates
- `google_sign_in` for Google authentication
- `shared_preferences` for token/user persistence

## Running the App

Run on macOS:

```sh
flutter run -d macos
```

Run on Android emulator:

```sh
flutter run -d android
```

By default, the app uses these backend API base URLs:

- Android emulator: `http://10.0.2.2:3000/api`
- macOS and other desktop targets: `http://localhost:3000/api`

Override the API URL:

```sh
flutter run --dart-define=API_BASE_URL=http://YOUR_HOST:3000/api
```

For a physical Android device, use your computer's LAN IP:

```sh
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3000/api
```

## Backend API

The app expects the API contract in `api.yaml`.

Main endpoints:

- `GET /home`
- `GET /leaderboard`
- `GET /account`
- `POST /ride/start`
- `POST /tracking`
- `POST /ride/stop`
- `POST /tasks/complete`
- `GET /debug/tracking`

The account page calls:

```text
GET /account
```

If `/account` fails, the app shows dummy account data and labels it with a `Dummy` tag.

## Maps and Routing

Task cards navigate to the task map page.

The route is:

- Start: Sendai Station
- Stop: Ayashi Station

Map tiles:

```text
https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png
```

Route geometry:

```text
https://router.project-osrm.org/route/v1/driving/{startLng},{startLat};{endLng},{endLat}
```

The current implementation uses OSRM's public demo server and the `driving` profile. For production or bicycle-accurate routing, replace it with a dedicated routing provider such as OSRM self-hosted, OpenRouteService, GraphHopper, or another bicycle-capable route API.

## Platform Notes

### Android

The app is configured for local HTTP development:

- `INTERNET` permission is enabled.
- Cleartext HTTP traffic is allowed.
- Android emulator uses `10.0.2.2` to reach the host machine.

### macOS

The app has macOS network client entitlement enabled so it can call the local backend and external map/route services in sandboxed builds.

### Sensors and GPS

The ride dashboard includes:

- GPS one-shot test
- live GPS stream
- accelerometer readings
- gyroscope readings

Location permission must be granted on the target device or simulator. If GPS is unavailable, the task map still shows the start/stop route and reports that current location is unavailable.

## Google Sign-In

The auth service supports a Google web client ID through `dart-define`:

```sh
flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_CLIENT_ID.apps.googleusercontent.com
```

The backend auth endpoint is currently expected at:

```text
POST {API_BASE_URL}/auth/google
```

## Validation

Format code:

```sh
dart format lib
```

Run static analysis:

```sh
flutter analyze --no-pub
```

Run tests:

```sh
flutter test
```

## Development Notes

- Keep API model changes aligned with `api.yaml`.
- Use `--dart-define=API_BASE_URL=...` instead of hard-coding local IP addresses.
- Do not use the public OpenStreetMap tile server directly for app traffic.
- The current route API is suitable for demos, not production traffic.
- The account page intentionally falls back to dummy data to keep the UI usable during backend downtime.
