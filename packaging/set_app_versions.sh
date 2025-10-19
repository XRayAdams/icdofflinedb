#!/bin/bash

echo "___________________________________________________________"
echo "Setting app version in all relevant files..."


# --- Configuration ---
PUBSPEC_FILE="pubspec.yaml"
DEBIAN_CONTROL_FILE="packaging/control"
DEBIAN_DESKTOP_FILE="packaging/gui/app.rayadams.icdofflinedb.desktop"
SNAP_YAML_FILE="snap/snapcraft.yaml"
SNAP_DESKTOP_FILE="snap/gui/icdofflinedb.desktop"
RPM_FILE="packaging/icdofflinedb.spec"
MACHINE_ARCH=$(uname -m)
DEBIAN_CONTROL_FILE_ARCH="amd64"

if [ "$MACHINE_ARCH" == "aarch64" ]; then
    MACHINE_ARCH="arm64"
    DEBIAN_CONTROL_FILE_ARCH="arm64"
    echo "Architecture was aarch64, updated to: $MACHINE_ARCH"
elif [ "$MACHINE_ARCH" == "x86_64" ]; then
    MACHINE_ARCH="x64"
    DEBIAN_CONTROL_FILE_ARCH="amd64"
fi
# ---------------------


# Check if files exist
if [ ! -f "$PUBSPEC_FILE" ]; then
    echo "Error: File not found: $PUBSPEC_FILE"
    exit 1
fi
if [ ! -f "$DEBIAN_CONTROL_FILE" ]; then
    echo "Error: File not found: $DEBIAN_CONTROL_FILE"
    exit 1
fi
if [ ! -f "$DEBIAN_DESKTOP_FILE" ]; then
    echo "Error: File not found: $DEBIAN_DESKTOP_FILE"
    exit 1
fi
if [ ! -f "$SNAP_YAML_FILE" ]; then
    echo "Error: File not found: $SNAP_YAML_FILE"
    exit 1
fi
if [ ! -f "$SNAP_DESKTOP_FILE" ]; then
    echo "Error: File not found: $SNAP_DESKTOP_FILE"
    exit 1
fi
if [ ! -f "$RPM_FILE" ]; then
    echo "Error: File not found: $RPM_FILE"
    exit 1
fi

# Read version from pubspec.yaml (extracts the line with 'version:' and gets the value after the space)
APP_VERSION=$(grep 'version:' $PUBSPEC_FILE | cut -d ' ' -f 2)

if [ -z "$APP_VERSION" ]; then
    echo "Error: Could not read version from $PUBSPEC_FILE."
    exit 1
fi

echo "Version '$APP_VERSION' found in $PUBSPEC_FILE"

# App details from pubspec.yaml for RPM spec
APP_VERSION_SHORT=$(grep 'version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)
APP_BUILD=$(grep 'version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f2)

# Use sed to find and replace the Version line in debian.yaml and desktop file
# This command looks for the line starting with '  Version:' and replaces the entire line.
sed -i "s/^\(\s*Version:\s*\).*\$/\1$APP_VERSION/" "$DEBIAN_CONTROL_FILE"
sed -i "s/^\(\s*Architecture:\s*\).*\$/\1$DEBIAN_CONTROL_FILE_ARCH/" "$DEBIAN_CONTROL_FILE"

sed -i "s/^\(\s*Version=\s*\).*\$/\1$APP_VERSION/" "$DEBIAN_DESKTOP_FILE"

sed -i "s/^\(\s*version:\s*\).*\$/\1$APP_VERSION/" "$SNAP_YAML_FILE"
sed -i "s/^\(\s*Version=\s*\).*\$/\1$APP_VERSION/" "$SNAP_DESKTOP_FILE"

# Update version in RPM spec file
sed -i "s/^\(\s*%define _version \s*\).*\$/\1$APP_VERSION_SHORT/" "$RPM_FILE"
sed -i "s/^\(\s*%define _release \s*\).*\$/\1$APP_BUILD/" "$RPM_FILE"

echo "Successfully updated version to $APP_VERSION in all relevant files."
