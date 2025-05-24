#!/usr/bin/bash
# Lists users with real shells, their password hashes, and last login times (clean format).
# Can only be run as root.

if [[ "$EUID" -ne 0 ]]; then
    echo "This must be run as root." >&2
    exit 1
fi

printf "%-15s %-65s %-30s\n" "Username" "Password Hash" "Last Login"
printf "%s\n" "$(head -c 120 < /dev/zero | tr '\0' '-')"

grep -E "(bash|zsh|fish|sh)$" /etc/passwd | cut -d: -f1 | while read -r user; do
    # Get password hash
    passwd_hash=$(sudo grep "^$user:" /etc/shadow | cut -d: -f2)

    # Get last login info
    lastlog_output=$(lastlog -u "$user" | tail -n 1)
    if echo "$lastlog_output" | grep -q "Never logged in"; then
        last_login="**Never logged in**"
    else
        # Strip username and terminal fields (columns 1-3), print from 4th field onward
        last_login=$(echo "$lastlog_output" | awk '{for (i=4; i<=NF; i++) printf $i " "; print ""}')
    fi

    # Print result
    printf "%-15s %-65s %-30s\n" "$user" "$passwd_hash" "$last_login"
done

