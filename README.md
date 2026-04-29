# Racheeta

Racheeta is a health-services marketplace mobile application. It allows patients to search for health service providers, make reservations, and apply for jobs. Health service providers can publish their services, offers, and jobs.

## Features
- Search and book health services.
- Provider dashboards.
- Job applications.
- Authentication (Email, Google).

## Setup
1. Ensure Flutter is installed.
2. Run `flutter pub get` to fetch dependencies.
3. The backend base URL is configured in `lib/core/config/app_config.dart`.
4. Run the app with `flutter run`.

## Build
To build a release APK, run:
`flutter build apk --release`

*Note: Production release requires valid signing keys.*
