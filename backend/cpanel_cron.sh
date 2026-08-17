#!/bin/bash
# ==============================================================================
# Biggopti cPanel Cron Job Execution Script
# Set up in cPanel -> Cron Jobs (e.g., every 12 hours: 0 */12 * * *)
# ==============================================================================

# Determine directory script path
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo "==================================================" >> cron.log
echo "Starting Biggopti Scraper Cron Job: $(date)" >> cron.log
echo "==================================================" >> cron.log

# Execute Python scraper and append output to cron.log
python3 main.py >> cron.log 2>&1

echo "Cron Job Execution Finished: $(date)" >> cron.log
