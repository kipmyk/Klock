# 🕰️ Klock

A premium, status-aware macOS Menu Bar app for tracking global time and weather with the style of [kipmyk](https://github.com/kipmyk).

![Klock Icon](https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/clock.svg)

## ✨ Features

- **Customizable Status Profiles**: Define your own time ranges and colors for:
    - 🟢 **Working**: Productive hours.
    - 🟡 **Awake**: Active but not working.
    - 🟠 **Annoying**: Late hours when calling might be an interruption.
    - 🟣 **Asleep**: Quiet hours.
- **Midnight Aesthetic**: Deep, eye-friendly dark theme inspired by premium world clocks.
- **Live Weather**: Real-time temperature and condition icons (powered by Open-Meteo).
- **Format Toggle**: Instantly switch between 12h (AM/PM) and 24h formats.
- **Smart Offsets**: Relative time offsets (e.g., +3h, -5h) calculation.
- **Persistence**: Your selected cities and status settings are saved automatically.

### 🍺 Homebrew

You can install **Klock** via Homebrew Cask. Since the repository is not named `homebrew-klock`, you need to tap it using the full URL:

```bash
brew tap kipmyk/klock https://github.com/kipmyk/Klock
brew install --cask klock
```

Or install directly (this will still attempt to tap automatically):

```bash
brew install --cask kipmyk/klock/klock
```

*Note: The Cask is located in the `Casks/` directory. The explicit tap command above is required because Homebrew expects the repository name to start with `homebrew-` for the shorthand command.*

### 💾 Manual Download
1. Download the latest `Klock.dmg` from the [Releases](https://github.com/kipmyk/Klock/releases) page.
2. Open the DMG and drag **Klock** to your `/Applications` folder.
3. Launch it! Look for the **Globe** icon in your Menu Bar.

## 🛠️ Building from Source

### Prerequisites
- macOS 14.0 or later
- Xcode 15+ / Swift 5.9+

### Steps
1. **Clone the repo**:
   ```bash
   git clone https://github.com/kipmyk/Klock.git
   cd Klock
   ```

2. **Build and Package**:
   Run the packaging script to create the `.app` bundle and a `.dmg`:
   ```bash
   chmod +x package.sh
   ./package.sh
   ```

3. **Install**:
   Move the generated `Klock.app` to your Applications:
   ```bash
   mv Klock.app /Applications/
   ```

## 🤝 Contributing

Feel free to open issues or submit pull requests. Let's make this the best world clock for Mac!

## 📜 License

MIT License. See `LICENSE` for details.
