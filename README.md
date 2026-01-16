# Heroku Buildpack: ImageMagick 7 + libheif 1.18+ (iOS 18 HEIC Support)

A Heroku buildpack that provides ImageMagick 7 with libheif 1.18+ for processing iOS 18+ HEIC images.

**Supports both Heroku-22 and Heroku-24 stacks.**

## Quick Start

```bash
# First, ensure your app is using Heroku-22 or Heroku-24
heroku stack
# If not, set it:
heroku stack:set heroku-24  # or heroku-22

# Add this buildpack to your app (before your language buildpack)
heroku buildpacks:add https://github.com/YOUR-USERNAME/heroku-buildpack-imagemagick-heif118 --index 1
heroku buildpacks:add heroku/ruby --index 2

# Or add to app.json
{
  "stack": "heroku-24",
  "buildpacks": [
    {
      "url": "https://github.com/YOUR-USERNAME/heroku-buildpack-imagemagick-heif118"
    },
    {
      "url": "heroku/ruby"
    }
  ]
}
```

## What's Included

- ImageMagick 7.1.1 (latest stable)
- libheif 1.18.2 (iOS 18 HEIC support)
- libde265 1.0.15 (HEIC decoder)
- libx265 (HEIC encoder)
- WebP support
- All standard ImageMagick delegates

## Supported Stacks

- ✅ **Heroku-24** (Ubuntu 24.04) - Default for new apps
- ✅ **Heroku-22** (Ubuntu 22.04) - Legacy support

## File Structure

```
heroku-buildpack-imagemagick-heif118/
├── bin/
│   ├── compile
│   ├── detect
│   └── release
├── build/
│   ├── imagemagick-22.tar.gz (Heroku-22 binaries)
│   └── imagemagick-24.tar.gz (Heroku-24 binaries)
├── Dockerfile.heroku-22
├── Dockerfile.heroku-24
├── build.sh
└── README.md
```

## Building the Binaries

The buildpack includes pre-built binaries for both stacks. To rebuild:

```bash
# Build for Heroku-24 (Ubuntu 24.04)
./build.sh 24

# Build for Heroku-22 (Ubuntu 22.04)
./build.sh 22

# Or build both
./build.sh 24 && ./build.sh 22

# This will create:
# - build/imagemagick-24.tar.gz
# - build/imagemagick-22.tar.gz
```

## Verifying Installation

After deploying:

```bash
heroku run bash -a your-app-name

# Check ImageMagick version
convert -version
# Should show libheif in delegates

# Check libheif version
heif-info --version
# Should show 1.18.2 or higher

# Test HEIC processing
convert test.heic test.png
```

## Troubleshooting

### "Too many auxiliary image references" error
This means libheif is too old. Ensure you're using this buildpack and purge cache:
```bash
heroku builds:cache:purge -a your-app-name
git commit --allow-empty -m "Rebuild with new buildpack"
git push heroku main
```

### Buildpack not activating
Ensure it's listed before your language buildpack:
```bash
heroku buildpacks
```

## Credits

Based on work from:
- drnic/heroku-buildpack-imagemagick-webp
- brandoncc/heroku-buildpack-vips
- Official ImageMagick and libheif projects
