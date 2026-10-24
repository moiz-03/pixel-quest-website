# Pixel Quest — Website

Static marketing site for the Pixel Quest Android app. Zero runtime dependencies,
no build step, no cookies, no analytics.

## Run locally

```bash
cd public
python3 -m http.server 8000
# open http://localhost:8000
```

## Developer Tools

### Verify Token Synchronization

To verify that design tokens in `public/assets/css/tokens.css` match the Flutter app's `lib/theme/app_colors.dart`, run the token sync PowerShell script:

```powershell
.\tools\sync-tokens.ps1
```