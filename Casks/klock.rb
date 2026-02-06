cask "klock" do
  version "1.0.0"
  sha256 "6622669b068b74e9a845fc21c17bd9df7caada2aa21a830aee5f26683e9453a2"

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
