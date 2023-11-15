# millis=$(gdate +%s%N)

# Check fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "fzf not found. Please install fzf."
    exit
fi

# Check jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq not found. Please install jq."
    exit
fi

HOME=$(echo ~)

if [ "$(uname -s)" == "MINGW32_NT" ] || [ "$(uname -s)" == "MINGW64_NT" ]; then
  HOME=$(cmd.exe /c "echo %HOMEPATH%" | tr -d '\r')
fi

# Use Chrome bookmarks as default
USE_CHROME=true

# Chrome bookmarks directory, default
if [ "$(uname)" == "Darwin" ]; then
  BOOKMARKS_FILE="${HOME}/Library/Application Support/Google/Chrome/Default/Bookmarks"
  CACHE_DIR="${HOME}/.cache/fzfbookmarks"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  BOOKMARKS_FILE="${HOME}/.config/google-chrome/Default/Bookmarks"
  CACHE_DIR="${HOME}/.cache/fzfbookmarks"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
  BOOKMARKS_FILE="/${HOME}AppData/Local/Google/Chrome/User Data/Default/Bookmarks"
  CACHE_DIR="/${HOME}AppData/Local/fzfbookmarks"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
  BOOKMARKS_FILE="/${HOME}AppData/Local/Google/Chrome/User Data/Default/Bookmarks"
  CACHE_DIR="/${HOME}AppData/Local/fzfbookmarks"
fi

# if Chrome bookmarks file does not exist, load firefox bookmarks
if [ ! -f "$BOOKMARKS_FILE" ]; then
  USE_CHROME=false
  if [ "$(uname)" == "Darwin" ]; then
    BOOKMARKS_DIR="${HOME}/Library/Application Support/Firefox/Profiles/"
    BOOKMARKS_FILE="${BOOKMARKS_DIR}$(ls ${HOME}/Library/Application\ Support/Firefox/Profiles/ | grep default-release)/places.sqlite"
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    BOOKMARKS_DIR="${HOME}/.mozilla/firefox/"
    BOOKMARKS_FILE="${BOOKMARKS_DIR}$(ls ${HOME}/.mozilla/firefox/ | grep default-release)/places.sqlite"
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    BOOKMARKS_DIR="/${HOME}AppData/Roaming/Mozilla/Firefox/Profiles/"
    BOOKMARKS_FILE="/${BOOKMARKS_DIR}$(ls /${HOME}AppData/Roaming/Mozilla/Firefox/Profiles/ | grep default-release)/places.sqlite"
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    BOOKMARKS_DIR="/${HOME}AppData/Roaming/Mozilla/Firefox/Profiles/"
    BOOKMARKS_FILE="/${BOOKMARKS_DIR}$(ls /${HOME}AppData/Roaming/Mozilla/Firefox/Profiles/ | grep default-release)/places.sqlite"
  fi
fi

if [ ! -f "$BOOKMARKS_FILE" ]; then
  echo "Bookmarks file not found. Currently only supports Google Chrome and Firefox."
  exit
fi

# This function parses the bookmarks file and saves the titles and URLs to the cache
# The cache is used to avoid parsing the bookmarks file every time
# The cache is updated if the bookmarks file was modified
function save_bookmarks_to_cache {
  if [ "$USE_CHROME" = true ]; then
    bookmarks_data=$(cat "$BOOKMARKS_FILE")
    bookmark_titles_0=$(jq '[.roots.bookmark_bar.children[] | select(.type == "url") | .name]' "$BOOKMARKS_FILE")
    bookmark_titles_1=$(jq '[.roots.bookmark_bar.children[] | select(.children) | .children[] | select(.type == "url") | .name]' "$BOOKMARKS_FILE")
    bookmark_titles_2=$(jq '[.roots.bookmark_bar.children[] | select(.children) | .children[] | select(.children) | .children[] | select(.type == "url") | .name]' "$BOOKMARKS_FILE")
    bookmark_titles="$bookmark_titles_0 $bookmark_titles_1 $bookmark_titles_2"
    bookmark_urls_0=$(jq '[.roots.bookmark_bar.children[] | select(.type == "url") | .url]' "$BOOKMARKS_FILE")
    bookmark_urls_1=$(jq '[.roots.bookmark_bar.children[] | select(.children) | .children[] | select(.type == "url") | .url]' "$BOOKMARKS_FILE")
    bookmark_urls_2=$(jq '[.roots.bookmark_bar.children[] | select(.children) | .children[] | select(.children) | .children[] | select(.type == "url") | .url]' "$BOOKMARKS_FILE")
    bookmark_urls="$bookmark_urls_0 $bookmark_urls_1 $bookmark_urls_2"
  else
    output_file="${CACHE_DIR}/bookmarks.json"
    cache_bookmarks_file="${CACHE_DIR}/cache_bookmarks.sqlite"
    cp "$BOOKMARKS_FILE" "$cache_bookmarks_file"

    sqlite3 "$cache_bookmarks_file" <<EOF > "$output_file"
.headers on
.mode json
.output stdout
SELECT h.url, b.title
FROM moz_places h
JOIN moz_bookmarks b
ON h.id = b.fk;
EOF

    bookmark_titles_0=($(jq '.[].title' "$output_file"))
    bookmark_urls_0=($(jq '.[].url' "$output_file"))

    # Merge elements between double quotes
    merged_titles=()
    current_title=""

    for title in "${bookmark_titles_0[@]}"; do
      if [[ $title == \"*\" ]]; then
        # Title starts and ends with a double quote
        merged_titles+=("${title}")
      elif [[ $title == \"* ]]; then
        # Title starts with a double quote
        current_title="${title}"
      elif [[ $title == *\" ]]; then
        # Title ends with a double quote
        current_title="${current_title} $title"
        merged_titles+=("${current_title}")
        current_title=""
      else
        # Title without double quotes
        current_title="${current_title} $title"
      fi
    done

    # Join array elements with newlines
    bookmark_titles=$(printf "%s\n" "${merged_titles[@]}")
    bookmark_urls=$(printf "%s\n" "${bookmark_urls_0[@]}")
  fi

  # Write the bookmark titles and URLs to cache
  echo $bookmark_titles > "${CACHE_DIR}/bookmark_titles"
  echo $bookmark_urls > "${CACHE_DIR}/bookmark_urls"
}


mkdir -p "$CACHE_DIR"
BOOKMARK_TITLES="${CACHE_DIR}/bookmark_titles"
BOOKMARK_URLS="${CACHE_DIR}/bookmark_urls"

# Check if the cache exists and is not empty
if [[ -f "$BOOKMARK_TITLES" && -f "$BOOKMARK_URLS" ]]; then
  if [ "$USE_CHROME" = true ]; then
    if [ "$(uname)" == "Darwin" ]; then
      BOOKMARKS_FILE_LASTMODIFIED=$(stat -f "%m" "$BOOKMARKS_FILE")
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      BOOKMARKS_FILE_LASTMODIFIED=$(stat -c "%Y" "$BOOKMARKS_FILE")
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
      BOOKMARKS_FILE_LASTMODIFIED=$(stat -c "%Y" "$BOOKMARKS_FILE")
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
      BOOKMARKS_FILE_LASTMODIFIED=$(stat -c "%Y" "$BOOKMARKS_FILE")
    fi
  else
    temp_bookmarks_file="${CACHE_DIR}/temp_bookmarks.sqlite"
    cp "$BOOKMARKS_FILE" "$temp_bookmarks_file"
    BOOKMARKS_FILE_LASTMODIFIED=$(sqlite3 "$temp_bookmarks_file" <<EOF
SELECT MAX(b.lastModified) AS latest_last_modified
FROM moz_bookmarks b;
EOF
)
    BOOKMARKS_FILE_LASTMODIFIED=$(($BOOKMARKS_FILE_LASTMODIFIED / 1000000))
  fi

  if [ "$(uname)" == "Darwin" ]; then
    BOOKMARK_TITLES_LASTMODIFIED=$(stat -f "%m" "$BOOKMARK_TITLES")
    BOOKMARK_URLS_LASTMODIFIED=$(stat -f "%m" "$BOOKMARK_URLS")
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    BOOKMARK_TITLES_LASTMODIFIED=$(stat -c "%Y" "$BOOKMARK_TITLES")
    BOOKMARK_URLS_LASTMODIFIED=$(stat -c "%Y" "$BOOKMARK_URLS")
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    BOOKMARK_TITLES_LASTMODIFIED=$(stat -c "%Y" "$BOOKMARK_TITLES")
    BOOKMARK_URLS_LASTMODIFIED=$(stat -c "%Y" "$BOOKMARK_URLS")
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    BOOKMARK_TITLES_LASTMODIFIED=$(stat -c "%Y" "$BOOKMARK_TITLES")
    BOOKMARK_URLS_LASTMODIFIED=$(stat -c "%Y" "$BOOKMARK_URLS")
  fi

  # If the bookmarks file is newer than the cache, update the cache
  if [[ "$BOOKMARKS_FILE_LASTMODIFIED" > "$BOOKMARK_TITLES_LASTMODIFIED" || "$BOOKMARKS_FILE_LASTMODIFIED" > "$BOOKMARK_URLS_LASTMODIFIED" ]]; then
    save_bookmarks_to_cache
  fi
# Initialize the cache
else
  save_bookmarks_to_cache
fi

bookmark_titles="$(<"$BOOKMARK_TITLES")"
bookmark_urls=$(<"$BOOKMARK_URLS")

IFS='"' read -a arr <<EOF
$bookmark_titles
EOF

bookmarks=()
for item in "${arr[@]}"; do
  if [[ -z "$item" || "$item" == $'\n' ]]; then
    continue
  fi
  case "$item" in
    '[ '|', '|' ]'|' ] [ '|' ] []'|' ') continue;;
    *) 
      bookmarks+=("$item")
    ;;
  esac
done


# echo "time taken: $(($(gdate +%s%N) - $millis))"

# Use fzf for fuzzy searching
selected_title=$(printf "%s\n" "${bookmarks[@]}" | fzf --preview "open {}" --height 25% --preview-window=down:0%:wrap)

IFS='"' read -a arr <<EOF
$bookmark_urls
EOF

urls=()
for item in "${arr[@]}"; do
  if [[ -z "$item" || "$item" == $'\n' ]]; then
    continue
  fi
  case "$item" in
    '[ '|', '|' ]'|' ] [ '|' ] []'|' ') continue;;
    *) 
      urls+=("$item")
    ;;
  esac
done

# Find the URL corresponding to the selected title
for i in "${!bookmarks[@]}"; do
  if [ "${bookmarks[i]}" = "$selected_title" ]; then
    selected_url="${urls[i]}"
    break
  fi
done

# Open the URL in Google Chrome
if [[ -n "$selected_url" ]]; then
  if [ "$USE_CHROME" = true ]; then
    if [ "$(uname)" == "Darwin" ]; then
      open -a "Google Chrome" "$selected_url"
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      google-chrome "$selected_url"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
      start chrome "$selected_url"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
      start chrome "$selected_url"
    fi
  else
    if [ "$(uname)" == "Darwin" ]; then
      open -a "Firefox" "$selected_url"
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      firefox "$selected_url"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
      start firefox "$selected_url"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
      start firefox "$selected_url"
    fi
  fi
fi
