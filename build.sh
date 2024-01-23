#!/bin/sh

# NOTE: simplified version of runme.sh script from the official Firefox

ARCH=$(flatpak --default-arch)
FREEDESKTOP_VERSION="23.08"

if [ -z $1 ]; then
  FIREFOX_BUILD_DIR="$HOME/development/projects/others/gecko-dev-fork/objdir"
else
  FIREFOX_BUILD_DIR=$1
fi

# Init
flatpak remote-add --user --if-not-exists --from flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --user -y flathub org.mozilla.firefox.BaseApp//$FREEDESKTOP_VERSION --no-deps
flatpak install --user -y flathub org.freedesktop.Sdk $FREEDESKTOP_VERSION

# Clean
rm -rf build

# Build
flatpak build-init --base org.mozilla.firefox.BaseApp --base-version=${FREEDESKTOP_VERSION} build org.mozilla.firefox org.freedesktop.Sdk org.freedesktop.Platform 23.08

mkdir -p build/files/lib

cat <<EOF > build/metadata
[Application]
name=org.mozilla.firefox
runtime=org.freedesktop.Platform/${ARCH}/${FREEDESKTOP_VERSION}
sdk=org.freedesktop.Sdk/${ARCH}/${FREEDESKTOP_VERSION}
base=app/org.mozilla.firefox.BaseApp/${ARCH}/${FREEDESKTOP_VERSION}
[Extension org.mozilla.firefox.Locale]
directory=share/runtime/langpack
autodelete=true
locale-subset=true

[Extension org.freedesktop.Platform.ffmpeg-full]
directory=lib/ffmpeg
add-ld-path=.
no-autodownload=true
version=${FREEDESKTOP_VERSION}

[Extension org.mozilla.firefox.systemconfig]
directory=etc/firefox
no-autodownload=true
EOF

appdir=build/files
mkdir -p ${appdir}/lib/firefox
cp -rL $FIREFOX_BUILD_DIR/dist/bin/* ${appdir}/lib/firefox
install -d ${appdir}/lib/firefox
install -D -m644 -t "${appdir}/share/appdata" org.mozilla.firefox.appdata.xml
install -D -m644 -t "${appdir}/share/applications" org.mozilla.firefox.desktop
for size in 16 32 48 64 128; do
    install -D -m644 "${appdir}/lib/firefox/browser/chrome/icons/default/default${size}.png" "${appdir}/share/icons/hicolor/${size}x${size}/apps/org.mozilla.firefox.png"
done

mkdir -p "${appdir}/lib/firefox/distribution/extensions"
mkdir -p "${appdir}/lib//ffmpeg"
mkdir -p "${appdir}/etc/firefox"

appstream-compose --prefix="${appdir}" --origin=flatpak --basename=org.mozilla.firefox org.mozilla.firefox

# TODO langpacks

install -D -m644 -t "${appdir}/lib/firefox/distribution" distribution.ini
install -D -m644 -t "${appdir}/lib/firefox/distribution" policies.json
install -D -m644 -t "${appdir}/lib/firefox/browser/defaults/preferences" default-preferences.js
install -D -m755 launch-script.sh "${appdir}/bin/firefox"

flatpak build-finish build                                      \
        --allow=devel                                           \
        --share=ipc                                             \
        --share=network                                         \
        --socket=pulseaudio                                     \
        --socket=wayland                                        \
        --socket=x11                                            \
        --socket=pcsc                                           \
        --socket=cups                                           \
        --require-version=0.11.1                                \
        --persist=.mozilla                                      \
        --filesystem=xdg-download:rw                            \
        --filesystem=/run/.heim_org.h5l.kcm-socket              \
        --filesystem=xdg-run/speech-dispatcher:ro               \
        --device=all                                            \
        --talk-name=org.freedesktop.FileManager1                \
        --system-talk-name=org.freedesktop.NetworkManager       \
        --talk-name=org.a11y.Bus                                \
        --talk-name="org.gtk.vfs.*"                             \
        --own-name="org.mpris.MediaPlayer2.firefox.*"           \
        --own-name="org.mozilla.firefox.*"                      \
        --own-name="org.mozilla.firefox_beta.*"                 \
        --command=firefox
