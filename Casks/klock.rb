cask "klock" do
  version "1.0.0"
  sha256 "0c85f7ceac622dcff55660e986bb1c05175938bfe67694201a5aa35001803fc2"

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
