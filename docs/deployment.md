# Web deployment

The initial target is a Cloudflare Worker serving Flutter's static web build at
`pincheball.tlatoani.net`. No server runtime or backend is required.

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --release
npx wrangler@4 deploy --config wrangler.jsonc
```

Run deployment only from an authenticated Cloudflare account with access to the
`tlatoani.net` zone. Wrangler's custom domain configuration creates the Worker
hostname; inspect existing DNS and routes before the first production deploy.
No deployment has been performed by project initialization.

For Cloudflare Pages instead, publish `build/web` as the output directory after
running the Flutter build in an environment with Flutter installed, and attach
`pincheball.tlatoani.net` as the Pages custom domain. Choose one production host;
do not configure Pages and Workers to compete for the same hostname. Cloudflare
build images should not be assumed to include Flutter.

Development: `flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080`.

References: [Workers static assets](https://developers.cloudflare.com/workers/static-assets/)
and [Workers custom domains](https://developers.cloudflare.com/workers/configuration/routing/custom-domains/).
