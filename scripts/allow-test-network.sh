#!/bin/bash

# Script to add Swift test runner to macOS firewall exceptions
# This allows the test process to bind to network ports without security prompts

echo "Adding Swift test runner to firewall exceptions..."

# Find the Swift test binary path
SWIFT_PATH="/usr/bin/swift"

# Add to firewall using codesign or directly
# Note: This requires admin password

if [ -f "$SWIFT_PATH" ]; then
    echo "Found Swift at: $SWIFT_PATH"

    # Add firewall exception
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add "$SWIFT_PATH"
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp "$SWIFT_PATH"

    echo "✓ Swift test runner added to firewall exceptions"
    echo ""
    echo "You can now run: swift test"
else
    echo "✗ Swift not found at expected path"
    echo "Please run: which swift"
fi

echo ""
echo "If you continue to see prompts, you may need to:"
echo "1. Open System Settings > Privacy & Security > Firewall"
echo "2. Click 'Firewall Options...'"
echo "3. Add 'swift' manually"
