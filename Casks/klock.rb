cask "klock" do
  version "1.0"
  sha256 "fc6e16a07255c55ac86dc714a82e89e445dcbb9841fae8488a0814abc689e2dc"

  url "https://github.com/kipmyk/Klock/releases/download/v#{version}/Klock.dmg"
  name "Klock"
  desc "Premium world clock for the macOS Menu Bar"
  homepage "https://github.com/kipmyk/Klock"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :sonoma"

  app "Klock.app"

  zap trash: [
    "~/Library/Application Support/Klock",
    "~/Library/Preferences/com.kipmyk.klock.plist",
  ]
end
