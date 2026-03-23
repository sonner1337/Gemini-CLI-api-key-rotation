# 🚀 Smart Gemini CLI Key Rotation (with Auto-Failover)

A robust, production-ready wrapper for the official [Gemini CLI](https://github.com/google/gemini-cli). Transform your terminal into a high-throughput AI workstation by pooling multiple API keys with intelligent routing and automatic failure handling.

### 🎯 Key Features
*   **Round-Robin Rotation:** Automatically cycles through your pool of API keys on every command invocation.
*   **Smart Auto-Failover:** Detects `429 Resource Exhausted` (Rate Limit) errors, puts the exhausted key on a 1-hour "cooldown," and **instantly retries** the request with a fresh key.
*   **Zero-Loss TTY:** Maintains full terminal aesthetics, including colors and interactive input/output.
*   **Stealthy & Efficient:** Runs silently in the background without cluttering your workflow with debug logs.

---

### 🛠 Installation (Step-by-Step)

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/oravepo546-stack/Gemini-CLI-api-key-rotation.git
    cd Gemini-CLI-api-key-rotation
    ```

2.  **Add your API keys:**
    Create the configuration directory and populate your keys (one per line):
    ```bash
    mkdir -p ~/.gemini
    nano ~/.gemini/api_keys.txt
    ```

3.  **Run the installer:**
    ```bash
    chmod +x install.sh
    ./install.sh
    ```

4.  **Reload your terminal:**
    ```bash
    source ~/.bashrc
    ```

---

### 🚀 Usage
Simply use the `gemini` command as you normally would:
```bash
gemini "Write a complex asynchronous Python scraper"
```
If a key hits a quota limit, you will see a brief notification, and the command will automatically re-run using the next available key.

### 📂 Project Structure
*   `wrapper.sh` — The core rotation and retry logic.
*   `install.sh` — Setup script for aliases and permissions.
*   `~/.gemini/cooldowns/` — Directory tracking exhausted keys and their expiration timestamps.

---
*Built for developers who demand zero downtime. Happy hacking! 🏴‍☠️*
