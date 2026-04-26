cask "android-studio-linux" do
  version "2025.3.4.6,panda4"
  sha256 "32a7ff09acaa38b48d61c8882bee7e213022a8ba0d1f16c0073380facb509fd3"

  url "https://dl.google.com/dl/android/studio/ide-zips/#{version.csv.first}/android-studio#{"-#{version.csv.second}" if version.csv.second}-linux.tar.gz"
  name "Android Studio"
  desc "Official Android IDE (Stable branch)"
  homepage "https://developer.android.com/studio"

  livecheck do
    url "https://developer.android.com/studio/releases"
    regex(%r{href=.*?/ide-zips/(\d+(?:\.\d+)+)/android[._-]studio(?:[._-]([^"' >]+))?[._-]linux\.tar\.gz}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map do |match|
        match[1].present? ? "#{match[0]},#{match[1]}" : match[0]
      end
    end
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
    "~/.cache/Google/AndroidStudio#{version.major_minor}",
    "~/.config/Google/AndroidStudio#{version.major_minor}",
    "~/.local/share/Google/AndroidStudio#{version.major_minor}",
  ]

  caveats <<~EOS
    Android Studio requires the Android SDK to be installed.
    By default, it will be installed to ~/Android/Sdk on first launch.
  EOS
end
