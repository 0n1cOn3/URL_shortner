# Another Yet URL Shortner
## v2.0 — Portable URL Shortener for Linux & Termux

An open-source, portable URL shortener for Linux, Termux and other POSIX-like environments.

The Bash wrapper handles dependency installation, Python virtual environment creation, and launching.  
The Python script performs the actual URL shortening using multiple public providers.

<img src="https://i.ibb.co/n7vwYP7/Unbenannt.png" width="800px" height="auto">

---

## Features

- Shortens any valid HTTP/HTTPS URL
- Uses multiple URL shortening services in one run:
  - `tinyurl`, `clckru`, `isgd`, `osdb`, `chilpit`, `qpsru`, `dagd`
- URL validation using the `validators` Python library
- Simple loading animation (spinner) while shortening
- Colored, readable terminal output
- Portable Bash wrapper:
  - Automatically detects package manager:
    - `apt`, `dnf`, `pacman`, `brew`, `pkg` (Termux), `apk`
  - Creates and uses a local Python virtual environment (`venv/`)
  - Installs Python dependencies (`pyshorteners`, `validators`) into the venv only
  - Optionally uses “eye candy” tools (`toilet`, `boxes`, `lolcat`) for a fancy banner, but they are not required

---

## Project Structure

```text
URL_shortner/
├── shortner.py      # Python script with the core shortening logic
├── url.sh           # Bash wrapper (dependency install, venv, banner, launcher)
└── README.md        # This documentation

    Note: The Python file is intentionally named shortner.py to match the repository name.
```

## Requirements

General:

    A POSIX shell (`bash`)

    Internet connection (for package installation and for URL shortening)

    git to clone the repository

The wrapper will try to install core dependencies automatically:

- python3
- curl
On Debian/Ubuntu: python3-venv, python3-pip

Supported / auto-detected platforms:

- Debian / Ubuntu and derivatives (apt)
- Fedora / RHEL / CentOS (dnf)
- Arch Linux and derivatives (pacman)
- macOS with Homebrew (brew)
- Termux on Android (pkg)
- Alpine Linux (apk)

Installation & Basic Usage
1. Clone the repository

```bash
git clone https://github.com/onkarhanchate14/URL_shortner.git
cd URL_shortner
```

2. Make the wrapper executable
```bash
`chmod +x url.sh`
```

3. Run the URL shortener

```bash
`./url.sh`
```

What happens:

    The script detects your package manager.

    Missing core packages like python3 and curl are installed (if possible).

    A local Python virtual environment (venv/) is created (if not already present).

    Python modules pyshorteners and validators are installed into the venv.

    A banner is displayed.

    shortner.py is executed inside the virtual environment.

## Using the Shortener (Interactive Flow)

After the banner, the Python script will prompt you:

Enter URL:

For example:
https://example.com/some/path?param=value

Behaviour:

    If the URL is valid:

        The script validates it.

        It tries to shorten it using all configured services.

        For each successful provider, you get a line of output.

    If the URL is invalid:

        You see an error message.

        You can re-enter a URL.

Example output:

> [!TIP]
> Successfully Shortened URLs:
>
> [+] TINYURL: https://tinyurl.com/xxxxxxx
> [+] ISGD:    https://is.gd/yyyyyyy
> [+] DAGD:    https://da.gd/zzzzzzz

If every provider fails (e.g. `no internet`, `blocked services`, `etc`.), you will see:

> [!CAUTION]
> [!] Failed to shorten URL. Check internet connection or URL validity.

## Termux Usage (Android)

On Termux, the process is essentially the same. You only need to ensure git is available first:

```bash
pkg update
pkg install git -y
git clone https://github.com/onkarhanchate14/URL_shortner.git
cd URL_shortner
chmod +x url.sh
./url.sh
```

The wrapper will use pkg as the package manager and handle Python and dependency setup automatically (as far as Termux allows).

## Troubleshooting
No supported package manager found

> [!CAUTION]
> Error:
> [!] No supported package manager found.
> Please install `python3` and `python3-venv` manually.

Reason:

    You're using unlikely an unusual system or missing a standard package manager.

Fix:

    Install at least python3 and curl manually.

    On Debian/Ubuntu it also needd to be installed:

```bash
sudo apt-get update
sudo apt-get install python3-venv python3-pip -y
```

Then run:

```bash
./url.sh
```


> [!CAUTION]
> [!] Failed to create virtual environment.

or 

> [!CAUTION]
> [!] Error: during venv setup

Try running: 

```bash
sudo apt install python3-full (or python3-venv
```

Fix (Debian/Ubuntu):

```bash
sudo apt-get update
sudo apt-get install python3-venv python3-pip -y
./url.sh
```

On other distributions, install the equivalent `Python venv` package (often part of the main `Python` package).
No shortened URLs returned

If the script finishes without giving any shortened URL:

    Ensure your internet connection is working.

    Make sure the URL starts with http:// or https://.

    Try a simpler test link like:

    https://example.com

    Some services might be temporarily down; the script will skip failing services and continue with the rest.

## Contact

Feel free to contact the author:

E-Mail: casbergskull@gmail.com

Bug reports, improvements, and contributions are always welcome.
