#!/bin/bash

# Check if both bot token and chat ID are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <bot_token> <chat_id>"
    exit 1
fi

# Telegram Bot token and chat ID
TELEGRAM_BOT_TOKEN="$1"
TELEGRAM_CHAT_ID="$2"

# Function to execute the command
run_command() {
    echo "Running command: curl -sL1 avail.sh | bash"
    if output=$(curl -sL1 avail.sh | bash); then
        if [[ "$output" =~ "Avail stopped" ]]; then
            echo "Avail stopped. No further action needed."
            return 0
        else
            echo "Command executed successfully!"
            return 0
        fi
    else
        echo "Command failed."
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

# Loop until the command succeeds
while true; do
    echo "Attempting to execute the command..."
    if run_command; then
        break  # Exit the loop if the command succeeds or Avail is stopped
    else
        echo "Command failed. Retrying in 5 seconds..."
        send_telegram_message "Error executing script on $(hostname), please check."
        sleep 5  # Wait for 5 seconds before retrying
    fi
done
