#!/usr/bin/env bash
# album_info_to_mysql_and_copy.sh
# Usage: ./album_info_to_mysql_and_copy.sh /path/to/music/folder

set -euo pipefail

MUSIC_DIR="${1:-}"
DEST_DIR="/var/www/music"

if [[ -z "$MUSIC_DIR" ]]; then
  echo "Usage: $0 /path/to/music/folder"
  exit 1
fi

# MySQL credentials
DB_USER="root"
DB_PASS="verysecurepassword"
DB_NAME="gotify"

# Ensure destination folder exists
mkdir -p "$DEST_DIR"

# Check dependencies
command -v exiftool >/dev/null 2>&1 || { echo "exiftool not found"; exit 1; }
command -v mysql >/dev/null 2>&1 || { echo "mysql CLI not found"; exit 1; }
command -v md5sum >/dev/null 2>&1 || { echo "md5sum not found"; exit 1; }

# Function to safely escape single quotes
esc_sql() {
	printf "%s" "$1" | sed "s/'/''/g"
}

# Find music files recursively
find "$MUSIC_DIR" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.m4a" -o -iname "*.ogg" -o -iname "*.wav" \) -print0 |
while IFS= read -r -d '' FILE; do
	# Extract metadata
	ARTIST=$(exiftool -Artist -b "$FILE" 2>/dev/null || echo "")
	ALBUM=$(exiftool -Album -b "$FILE" 2>/dev/null || echo "")
	TRACK=$(exiftool -TrackNumber -b "$FILE" 2>/dev/null || echo "")
	SONG=$(exiftool -Title -b "$FILE" 2>/dev/null || echo "")
	MD5=$(md5sum "$FILE" | awk '{print $1}')

	# Extract file extension (lowercase)
	EXT="${FILE##*.}"
	EXT="${EXT,,}"

	# Escape values for SQL
	ARTIST_ESC=$(esc_sql "$ARTIST")
	ALBUM_ESC=$(esc_sql "$ALBUM")
	TRACK_ESC=$(esc_sql "$TRACK")
	SONG_ESC=$(esc_sql "$SONG")
	MD5_ESC=$(esc_sql "$MD5")
	EXT_ESC=$(esc_sql "$EXT")

	# Locate cover image (optional)
	DIRNAME=$(dirname "$FILE")
	COVER_FILE="$DIRNAME/cover.jpg"
	COVER_PATH_DB=""

	if [[ -f "$COVER_FILE" ]]; then
		COVER_MD5=$(md5sum "$COVER_FILE" | awk '{print $1}')
		COVER_EXT="${COVER_FILE##*.}"
		COVER_HASH_FILE="$COVER_MD5.$COVER_EXT"
		cp "$COVER_FILE" "$DEST_DIR/$COVER_HASH_FILE"
		COVER_PATH_DB=$(esc_sql "$COVER_HASH_FILE")
		echo "Copied cover: $COVER_FILE → $COVER_HASH_FILE"
	else
		echo "❌ No cover file found in directory: $DIRNAME (expected cover.jpg)"
		echo "Aborting album import."
		exit 1
	fi

	# Insert or get album ID
	ALBUM_ID=$(mysql -N -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "
		SELECT id FROM album WHERE name='$ALBUM_ESC' AND artist='$ARTIST_ESC' LIMIT 1;
	")

	if [[ -z "$ALBUM_ID" ]]; then
		mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "
			INSERT INTO album (name, artist, cover_path)
			VALUES ('$ALBUM_ESC', '$ARTIST_ESC', '$COVER_PATH_DB');
		"
		ALBUM_ID=$(mysql -N -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT LAST_INSERT_ID();")
		echo "Added new album: $ALBUM by $ARTIST (ID: $ALBUM_ID)"
	else
		# Optionally update cover_path if missing
		if [[ -n "$COVER_PATH_DB" ]]; then
			mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "
				UPDATE album SET cover_path='$COVER_PATH_DB'
				WHERE id=$ALBUM_ID AND (cover_path IS NULL OR cover_path='');
			"
		fi
	fi

	# Insert into music table (with extension column)
	mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "
		INSERT INTO music (hash, album_id, song, track_number, extension)
		VALUES ('$MD5_ESC', '$ALBUM_ID', '$SONG_ESC', '$TRACK_ESC', '$EXT_ESC');
	"
	echo "Inserted: $SONG (album_id: $ALBUM_ID, extension: $EXT)"

	# Copy & rename music file
	NEW_FILE="$DEST_DIR/$MD5.$EXT"
	cp "$FILE" "$NEW_FILE"
	echo "Copied & renamed to: $NEW_FILE"
done

echo "✅ Done! All files and covers inserted into DB and copied to $DEST_DIR"
