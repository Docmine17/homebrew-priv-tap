cask "android-studio-linux" do
  version "2025.3.2.6"
  sha256 "32942d8cd7688192cf3cd07bf282fb120035b9bd9b56e6f13c5540e6d39807e9"

  url "https://dl.google.com/dl/android/studio/ide-zips/#{version}/android-studio-panda2-linux.tar.gz"
  name "Android Studio"
  desc "The official Android IDE (Stable branch)"
  homepage "https://developer.android.com/studio"

  livecheck do
    url "https://developer.android.com/studio/releases"
    regex(/android-studio-(\d+(?:\.\d+)+)-linux\.tar\.gz/i)
  end

  binary "android-studio/bin/studio"
  artifact "android-studio.desktop",
           target: "#{Dir.home}/.local/share/applications/android-studio.desktop"
  artifact "android-studio.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/256x256/apps/android-studio.png"

  preflight do
    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons/hicolor/256x256/apps"

    # Copy icon from extracted archive
    icon_source = "#{staged_path}/android-studio/bin/studio.png"
    FileUtils.cp icon_source, "#{staged_path}/android-studio.png" if File.exist?(icon_source)

    File.write("#{staged_path}/android-studio.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Android Studio
      Comment=The official Android IDE
      Exec="#{HOMEBREW_PREFIX}/bin/studio" %f
      Icon=#{Dir.home}/.local/share/icons/hicolor/256x256/apps/android-studio.png
      Terminal=false
      StartupNotify=true
      StartupWMClass=jetbrains-studio
      Categories=Development;IDE;
      MimeType=application/x-extension-iml;
    EOS
  end

  zap trash: [
    "~/.android",
    "~/.config/Google/AndroidStudio#{version.major_minor}",
    "~/.local/share/Google/AndroidStudio#{version.major_minor}",
    "~/.cache/Google/AndroidStudio#{version.major_minor}",
    "~/AndroidStudioProjects",
  ]

  caveats <<~EOS
    Android Studio requires the Android SDK to be installed.
    By default, it will be installed to ~/Android/Sdk on first launch.
  EOS
end
