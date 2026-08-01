#!/bin/sh
#
# Rebuilds Kudao/Utilities/EnvConfig.swift from the platform-generated
# Kudao/Config.swift, keeping only characters that can legally appear in a
# configuration value.
#
# Why this exists: Config.swift is regenerated on every build by copying the
# project's public environment variables verbatim into Swift source. A value
# pasted from a web page can carry invisible characters, and the compiler then
# refuses to parse the file:
#
#   error: unprintable ASCII character found in source file
#
# One of this project's Associates tags is stored as a literal tab followed by a
# space (0x09 0x20) before the tag itself, which is exactly what triggered that
# error. Tabs are therefore stripped like any other control character; nothing
# in a URL, key or tag ever needs one.
#
# Config.swift is excluded from compilation (EXCLUDED_SOURCE_FILE_NAMES), and
# the app reads its values from the file produced here instead, so a stray byte
# in one variable can no longer break the whole build.
#
# Values are reduced to printable ASCII minus the two characters that would
# escape a Swift string literal, `"` and `\`, then trimmed of surrounding
# spaces. URLs, API keys and Associates tags are ASCII by definition, so nothing
# meaningful is lost.

SOURCE="${SRCROOT}/Kudao/Config.swift"
TARGET="${SRCROOT}/Kudao/Utilities/EnvConfig.swift"
DRAFT="${TMPDIR:-/tmp}/kudao-env-config.swift"

# Printable ASCII except " (042) and \ (134). Tabs, newlines and every other
# control character fall outside this set and are removed.
SAFE='\040-\041\043-\133\135-\176'
# Drops the spaces left at either end once invisible characters are gone.
TRIM='s/^ *//; s/ *$//'
# Matches `    static let NAME = "value"` and prints NAME=value.
EXTRACT='s/^[[:space:]]*static let \([A-Za-z_][A-Za-z0-9_]*\)[[:space:]]*=[[:space:]]*"\(.*\)"[[:space:]]*$/\1=\2/p'

if [ ! -f "$SOURCE" ]; then
  echo "warning: Config.swift not found at $SOURCE, keeping EnvConfig.swift as is"
  exit 0
fi

# `allValues` is a dictionary literal, not a string constant, so it never
# matches the extraction pattern and cannot be mistaken for a variable.
NAMES=$(LC_ALL=C sed -n "$EXTRACT" "$SOURCE" | cut -d= -f1)

if [ -z "$NAMES" ]; then
  echo "warning: no environment variables found in Config.swift, keeping EnvConfig.swift as is"
  exit 0
fi

{
  echo "// EnvConfig.swift - regenerated at build time by Scripts/generate-env-config.sh"
  echo "//"
  echo "// Values are copied from the platform-generated Config.swift with every"
  echo "// non-printable character removed, so an invisible byte pasted into a project"
  echo "// setting cannot break the build. Do not edit by hand."
  echo ""
  echo "import Foundation"
  echo ""
  echo "enum Config {"

  for NAME in $NAMES; do
    VALUE=$(LC_ALL=C sed -n "$EXTRACT" "$SOURCE" \
      | grep "^${NAME}=" \
      | head -1 \
      | cut -d= -f2- \
      | LC_ALL=C tr -cd "$SAFE" \
      | LC_ALL=C sed "$TRIM")
    printf '    static let %s = "%s"\n' "$NAME" "$VALUE"
  done

  echo ""
  echo "    static let allValues: [String: String] = ["
  for NAME in $NAMES; do
    printf '        "%s": %s,\n' "$NAME" "$NAME"
  done
  echo "    ]"
  echo "}"
} > "$DRAFT"

if cmp -s "$DRAFT" "$TARGET"; then
  rm -f "$DRAFT"
  exit 0
fi

if ! cat "$DRAFT" > "$TARGET"; then
  echo "error: could not write $TARGET"
  rm -f "$DRAFT"
  exit 1
fi

rm -f "$DRAFT"
echo "note: regenerated EnvConfig.swift from Config.swift"
exit 0
