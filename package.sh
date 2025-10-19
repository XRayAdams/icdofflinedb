#!/bin/bash
set -e

echo "Building and packaging the app..."

MACHINE_ARCH=$(uname -m)
DEBIAN_ARCH="amd64"
APP_ID="app.rayadams.icdofflinedb"

if [ "$MACHINE_ARCH" == "aarch64" ]; then
    MACHINE_ARCH="arm64"
    DEBIAN_ARCH="arm64"
elif [ "$MACHINE_ARCH" == "x86_64" ]; then
    MACHINE_ARCH="x64"
    DEBIAN_ARCH="amd64"
fi

# Build the app
flutter clean
flutter build linux --release

# Set app versions to all files for packaging
packaging/set_app_versions.sh
rm -rf dist
mkdir -p dist

# App details from pubspec.yaml
APP_NAME=$(grep 'name:' pubspec.yaml | awk '{print $2}')
APP_VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)
APP_BUILD=$(grep 'version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f2)

# Package DEB
echo "___________________________________________________________"
echo "Packaging DEB..."

PACKAGE_DIR="$APP_NAME-$APP_VERSION+$APP_BUILD-$DEBIAN_ARCH"

# Create the package directory
rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR/usr/local/lib/$APP_NAME"
mkdir -p "$PACKAGE_DIR/usr/share/applications"
mkdir -p "$PACKAGE_DIR/usr/share/icons"
mkdir -p "$PACKAGE_DIR/usr/share/metainfo"

# Copy the built app to the package directory
cp -r build/linux/"$MACHINE_ARCH"/release/bundle/* "$PACKAGE_DIR/usr/local/lib/$APP_NAME"
cp packaging/gui/$APP_ID.desktop "$PACKAGE_DIR/usr/share/applications/"
cp packaging/gui/$APP_ID.png "$PACKAGE_DIR/usr/share/icons/"
cp packaging/$APP_ID.metainfo.xml "$PACKAGE_DIR/usr/share/metainfo/"

# Copy control file
mkdir -p "$PACKAGE_DIR/DEBIAN"
cp packaging/control "$PACKAGE_DIR/DEBIAN/control"

# Build the .deb package
dpkg-deb --build "$PACKAGE_DIR"

# Clean up
rm -rf "$PACKAGE_DIR"

cp "$PACKAGE_DIR.deb" dist/
rm "$PACKAGE_DIR.deb"

echo "DEB package created in dist/"

echo "___________________________________________________________"
# Package RPM
echo "Preparing RPM package"

# Create RPM build directories
RPM_BUILD_ROOT="$(pwd)/rpmbuild"

mkdir -p "$RPM_BUILD_ROOT/BUILD"
mkdir -p "$RPM_BUILD_ROOT/RPMS"
mkdir -p "$RPM_BUILD_ROOT/SOURCES"
mkdir -p "$RPM_BUILD_ROOT/SPECS"
mkdir -p "$RPM_BUILD_ROOT/SRPMS"

CHANGE_DATE=$(date +"%a %b %d %Y")
CHANGE_DATE="$CHANGE_DATE Konstantin Adamov (xrayadamo@gmail.com) - $APP_VERSION-$APP_BUILD"
sed "s/^*loghere$/* $CHANGE_DATE/" "packaging/$APP_NAME.spec" > "$RPM_BUILD_ROOT/SPECS/$APP_NAME.spec"

# Copy desktop and icon files, replacing Exec and TryExec with app name , by default it has full path for debian package
sed -e "s/Icon=$APP_ID/Icon=$APP_NAME/" -e "s/^\(Exec\|TryExec\)=.*$/\1=$APP_NAME/" "packaging/gui/$APP_ID.desktop"  > "$RPM_BUILD_ROOT/SOURCES/$APP_ID.desktop"
cp packaging/gui/"$APP_ID".png "$RPM_BUILD_ROOT/SOURCES/"
cp packaging/"$APP_ID".metainfo.xml "$RPM_BUILD_ROOT/SOURCES/"

# Package the application files into a tarball
pushd build/linux/"$MACHINE_ARCH"/release || exit
tar -czvf "$RPM_BUILD_ROOT/SOURCES/$APP_NAME-$APP_VERSION.tar.gz" bundle
popd || exit

# Build the RPM
rpmbuild -bb \
    --define "_topdir $RPM_BUILD_ROOT" \
    --define "_name $APP_NAME" \
    --define "_version $APP_VERSION" \
    --define "_release $APP_BUILD" \
    "$RPM_BUILD_ROOT/SPECS/$APP_NAME.spec"

# Move the RPM to the dist directory
find "$RPM_BUILD_ROOT/RPMS" -name "*.rpm" -exec mv {} dist/ \;

# Clean up
rm -rf "$RPM_BUILD_ROOT"
echo "RPM package created in dist/"

echo "___________________________________________________________"

# Package TAR
echo "Preparing TAR archive"

ARCHIVE_NAME="${APP_NAME}-${APP_VERSION}+${APP_BUILD}-${MACHINE_ARCH}.tar.gz"
FULL_ARCHIVE_PATH="dist/${ARCHIVE_NAME}"
SOURCE_DIR="build/linux/${MACHINE_ARCH}/release/bundle"

tar -czvf "$FULL_ARCHIVE_PATH" -C "$SOURCE_DIR" . > /dev/null
echo "TAR archive created in dist/"
echo "___________________________________________________________"
