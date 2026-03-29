echo "Removing .NET installation..."

# remove dotnet directory
sudo rm -rf /usr/local/dotnet

# remove possible symlink
sudo rm -f /usr/bin/dotnet

# remove user-level installs if any
sudo rm -rf ~/.dotnet

echo "Verifying removal..."

if command -v dotnet >/dev/null 2>&1; then
    echo "dotnet still exists on system"
else
    echo ".NET successfully removed"
fi