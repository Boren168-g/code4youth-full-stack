#!/usr/bin/env bash
# Stop the stack. Data in the mysql_data volume is preserved.
#
#   ./scripts/down.sh          stop containers, keep the database
#   ./scripts/down.sh --wipe   stop AND permanently delete the database
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

if [ "${1:-}" = "--wipe" ]; then
    echo "This deletes the mysql_data volume. All local data is lost."
    read -r -p "Type 'wipe' to confirm: " reply
    if [ "$reply" != "wipe" ]; then
        echo "Cancelled."
        exit 0
    fi
    compose down -v
    echo "Stack stopped and data volume removed."
else
    compose down
    echo "Stack stopped. Data preserved — run ./scripts/up.sh to resume."
fi
