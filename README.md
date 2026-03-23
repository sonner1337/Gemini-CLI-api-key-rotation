# 🚀 Smart Gemini CLI Key Rotation (with Auto-Failover)

Умный обертчик (wrapper) для официального [Gemini CLI](https://github.com/google/gemini-cli), который превращает твой терминал в неубиваемый инструмент с бесконечной квотой. 

### 🎯 Что это умеет?
*   **Round-Robin Rotation:** Автоматически меняет API ключ при каждом запуске.
*   **Smart Auto-Failover:** Если ключ поймал `429 Resource Exhausted`, скрипт банит его на 1 час и **мгновенно перезапускает** команду со следующим ключом. Ты этого даже не заметишь!
*   **Zero-Loss TTY:** Не ломает цвета в терминале и интерактивный ввод.
*   **Clean & Silent:** Никаких лишних логов, только твои ответы.

---

### 🛠 Установка (Step-by-Step)

1. **Клонируй репозиторий:**
   ```bash
   git clone https://github.com/oravepo546-stack/Gemini-CLI-api-key-rotation.git
   cd Gemini-CLI-api-key-rotation
   ```

2. **Добавь свои ключи:**
   Создай файл `~/.gemini/api_keys.txt` и вставь туда свои ключи (каждый с новой строки):
   ```bash
   mkdir -p ~/.gemini
   nano ~/.gemini/api_keys.txt
   ```

3. **Запусти установщик:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

4. **Обнови терминал:**
   ```bash
   source ~/.bashrc
   ```

---

### 🚀 Как пользоваться?
Просто используй `gemini` как обычно:
```bash
gemini "Напиши злой скрипт на Python"
```
Если ключ исчерпает лимиты, ты увидишь предупреждение, и команда сама выполнится заново. 

### 📂 Структура проекта
*   `wrapper.sh` — Само ядро ротатора.
*   `install.sh` — Скрипт для настройки алиасов и прав.
*   `~/.gemini/cooldowns/` — Папка, где хранятся "уставшие" ключи.

---
*Сделано для тех, кто не любит ждать. Удачного хакинга! 🏴‍☠️*
