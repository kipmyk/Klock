cask "klock" do
  version "1.0.0"
  sha256 "e1a8ff7824fd3b5dbf359df2e7074aae9ed52858710925cadf049e5c6f93a69f"

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
