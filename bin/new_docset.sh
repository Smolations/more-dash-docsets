#!/bin/bash

# determine the path to this script.
THIS_SCRIPT_PATH="${BASH_SOURCE[0]}"
if [ -h "${THIS_SCRIPT_PATH}" ]; then
    while [ -h "${THIS_SCRIPT_PATH}" ]; do
        THIS_SCRIPT_PATH=`readlink "${THIS_SCRIPT_PATH}"`
    done
fi
pushd . > /dev/null
cd `dirname ${THIS_SCRIPT_PATH}` > /dev/null
export THIS_SCRIPT_PATH=`pwd`;
popd  > /dev/null



if [ -z "$1" ]; then
	echo "You must pass the docset file name as the first parameter."
	echo "This will be the same as what is displayed in Dash's left"
	echo "nav unless you pass a second parameter (display name)."
fi

docsetName="$1"
displayName="$docsetName"
[ -n "$2" ] && displayName="$2"
docsetPath="${THIS_SCRIPT_PATH}/.."
docsetFile="${docsetPath}/${docsetName}.docset"
contentsPath="${docsetFile}/Contents"
resourcesPath="${contentsPath}/Resources"
documentsPath="${resourcesPath}/Documents"
plistName="Info.plist"
plistPath="${docsetPath}/resources/${plistName}"
plistTempPath="${plistPath}.tmp"

# Create the Docset Folder
mkdir -p "$documentsPath"

# Create the Info.plist File (from template)
if [ -f "$plistPath" ]; then
    cat "$plistPath" > "$plistTempPath"
    sed -i '' "s/displayName/${displayName}/" "$plistTempPath"
    cp -f "$plistTempPath" "${contentsPath}/${plistName}"
    rm -f "$plistTempPath"
else
    echo "WARNING:  Could not find plist template!"
fi

# Create the SQLite Index
cd "$resourcesPath"
sqlite3 docSet.dsidx 'CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);'
sqlite3 docSet.dsidx 'CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);'
echo "SQLite index created. Insert queries using:"
echo "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('name', 'type', 'path');"
echo
echo "Docset created!"
echo
echo "Copy HTML to: ${documentsPath}"
exit 0
