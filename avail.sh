#!/bin/bash

# Check if both bot token and chat ID are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <bot_token> <chat_id>"
    exit 1
fi

# Telegram Bot token and chat ID
TELEGRAM_BOT_TOKEN="$1"
TELEGRAM_CHAT_ID="$2"
LOG_FILE="script_log.txt"

# Function to execute the command
run_command() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Running command: curl -sL1 avail.sh | bash" | tee -a "$LOG_FILE"
    if output=$(curl -sL1 avail.sh | bash 2>&1 | tee -a "$LOG_FILE"); then
        if [[ "$output" =~ "Avail stopped" ]]; then
            echo "$(date +'%Y-%m-%d %H:%M:%S') - Avail stopped. Retrying command." | tee -a "$LOG_FILE"
            return 1
        else
            echo "$(date +'%Y-%m-%d %H:%M:%S') - Command executed successfully!" | tee -a "$LOG_FILE"
            return 0
        fi
    else
        echo "$(date +'%Y-%m-%d %H:%M:%S') - Command failed." | tee -a "$LOG_FILE"
        return 1
    fi
}

# Function to send a message to Telegram
send_telegram_message() {
    local message="$1"
    local telegram_api_url="https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage"
    curl -s -X POST "$telegram_api_url" \
        -d "chat_id=$TELEGRAM_CHAT_ID" \
        -d "text=$message" >/dev/null
}

# Function to handle Ctrl+C
cleanup() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Script stopped by user. Exiting..." | tee -a "$LOG_FILE"
    exit 0
}

# Trap Ctrl+C and call the cleanup function
trap cleanup SIGINT

# Loop until the command succeeds
while true; do
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Attempting to execute the command..." | tee -a "$LOG_FILE"
    if run_command; then
        break  # Exit the loop if the command succeeds
    else
        echo "$(date +'%Y-%m-%d %H:%M:%S') - Command failed. Retrying in 5 seconds..." | tee -a "$LOG_FILE"
        send_telegram_message "Error executing script on $(hostname), please check."
        sleep 5  # Wait for 5 seconds before retrying
    fi
done
