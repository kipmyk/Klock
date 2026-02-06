cask "klock" do
  version "1.0.0"
  sha256 "e315dc1f399b1910e0ab6e9084f91aeb9de25aab272916f9693f113ce7f1205d"

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
