#!/usr/bin/env python3
import sys
import time
import threading
import itertools
import random
import pyshorteners
import validators

# ==============================================================================
# Configuration & Colors
# ==============================================================================

class Colors:
    RED = '\033[1;31m'
    GREEN = '\033[1;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[1;34m'
    MAGENTA = '\033[1;35m'
    CYAN = '\033[1;36m'
    RESET = '\033[0m'
    
    @staticmethod
    def random():
        return random.choice([Colors.RED, Colors.GREEN, Colors.YELLOW, 
                              Colors.BLUE, Colors.MAGENTA, Colors.CYAN])

# Control flag for the loading animation
stop_animation = threading.Event()

# ==============================================================================
# Helper Functions
# ==============================================================================

def animate(message="Processing"):
    """
    Runs a loading animation in a separate thread.
    """
    for c in itertools.cycle(['|', '/', '-', '\\']):
        if stop_animation.is_set():
            break
        sys.stdout.write(f'\r{Colors.YELLOW}{message} {c} {Colors.RESET}')
        sys.stdout.flush()
        time.sleep(0.1)
    # Clear the loading line when done
    sys.stdout.write('\r' + ' ' * (len(message) + 4) + '\r')
    sys.stdout.flush()

def get_valid_url():
    """
    Prompts user for input and validates it using a loop.
    No recursion used (safer).
    """
    print(f'{Colors.MAGENTA}')
    while True:
        try:
            url = input('Enter URL: ').strip()
            # Basic check to ensure http/https is present for validators
            if not url.startswith(('http://', 'https://')):
                # Try appending https for validation check, or warn user
                pass 
            
            if validators.url(url):
                print(f'{Colors.GREEN}URL is valid.{Colors.RESET}\n')
                time.sleep(0.5)
                return url
            else:
                print(f'{Colors.RED}[!] Invalid URL. Please include http:// or https://{Colors.RESET}')
        except KeyboardInterrupt:
            print(f"\n{Colors.RED}Exiting...{Colors.RESET}")
            sys.exit(0)

# ==============================================================================
# Main Logic
# ==============================================================================

def main():
    # 1. Get Input
    long_url = get_valid_url()
    
    print(Colors.random() + "=" * 50)
    print("     URL Shortener in progress, please wait...")
    print("     Please keep your data connection active.")
    print("=" * 50 + Colors.RESET)
    print("")

    # 2. Setup Shortener
    s = pyshorteners.Shortener()
    results = []

    # List of attributes in pyshorteners library to try.
    # Note: Some require API keys, these are generally the open ones.
    services = ['tinyurl', 'clckru', 'isgd', 'osdb', 'chilpit', 'qpsru', 'dagd']

    # 3. Start Animation
    t = threading.Thread(target=animate, args=("Shortening...",))
    t.start()

    # 4. Process Shortening (Loop through services)
    for service_name in services:
        try:
            # Dynamically get the shortener function: e.g., s.tinyurl.short
            if hasattr(s, service_name):
                provider = getattr(s, service_name)
                short_url = provider.short(long_url)
                
                # Check if it actually returned a valid string/link
                if short_url and "http" in short_url:
                    results.append(f"{service_name.upper()}: {short_url}")
        except Exception:
            # If a service fails (timeout/offline), we just skip it
            continue

    # 5. Stop Animation
    stop_animation.set()
    t.join()

    # 6. Display Results
    if results:
        print(f"\n{Colors.CYAN}Successfully Shortened URLs:{Colors.RESET}\n")
        for link in results:
            print(f"{Colors.GREEN} [+] {link}{Colors.RESET}")
    else:
        print(f"\n{Colors.RED}[!] Failed to shorten URL. Check internet connection or URL validity.{Colors.RESET}")
    
    print("\n")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        stop_animation.set()
        print(f"\n{Colors.RED}Aborted by user.{Colors.RESET}")
        sys.exit(0)