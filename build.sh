#!/bin/bash
# Build script for creating ImageMagick binaries with libheif 1.18+

set -e

STACK=${1:-24}  # Default to Heroku-24

if [[ "$STACK" != "22" && "$STACK" != "24" ]]; then
    echo "Usage: ./build.sh [22|24]"
    echo "  22 = Build for Heroku-22 (Ubuntu 22.04)"
    echo "  24 = Build for Heroku-24 (Ubuntu 24.04, default)"
    exit 1
fi

echo "======================================"
echo "Building ImageMagick with libheif 1.18+"
echo "for Heroku-$STACK stack"
echo "======================================"
echo ""

# Create build directory
mkdir -p build

# Build the Docker image
echo "Building Docker image for Heroku-$STACK..."
docker build --no-cache -f Dockerfile.heroku-$STACK -t imagemagick-heif-builder:$STACK .

# Extract the tarball
echo ""
echo "Extracting binaries from Docker image..."
docker run --rm imagemagick-heif-builder:$STACK > build/imagemagick-$STACK.tar.gz

# Verify the tarball
if [ ! -f build/imagemagick-$STACK.tar.gz ]; then
    echo "ERROR: Failed to create imagemagick-$STACK.tar.gz"
    exit 1
fi

# Get file size
SIZE=$(du -h build/imagemagick-$STACK.tar.gz | cut -f1)
echo ""
echo "======================================"
echo "Build complete!"
echo "======================================"
echo "Binary size: $SIZE"
echo "Output: build/imagemagick-$STACK.tar.gz"
echo ""

# Test extraction
echo "Testing tarball extraction..."
rm -rf build/test
mkdir -p build/test
tar -xzf build/imagemagick-$STACK.tar.gz -C build/test

if [ -f build/test/imagemagick/bin/convert ]; then
    echo "✓ ImageMagick binary found"
    
    # Show version info
    echo ""
    echo "ImageMagick version:"
    build/test/imagemagick/bin/convert -version
    
    echo ""
    echo "libheif version:"
    build/test/imagemagick/bin/heif-info --version || echo "heif-info not found (check installation)"
    
    echo ""
    echo "======================================"
    echo "Build verified successfully!"
    echo "======================================"
    echo ""
    echo "Next steps:"
    echo "1. Commit the build/imagemagick-$STACK.tar.gz file to your repository"
    echo "2. Push to GitHub"
    echo "3. Set your app to use Heroku-$STACK:"
    echo "   heroku stack:set heroku-$STACK"
    echo "4. Add buildpack to your Heroku app:"
    echo "   heroku buildpacks:add https://github.com/YOUR-USERNAME/REPO-NAME --index 1"
    echo "5. Deploy your app"
else
    echo "ERROR: Build verification failed - convert binary not found"
    exit 1
fi

# Cleanup test directory
rm -rf build/test

echo ""
echo "Build complete! Ready to deploy."
