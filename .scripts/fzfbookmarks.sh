# Check fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "fzf not found. Please install fzf."
    exit
fi

# CHeck jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq not found. Please install jq."
    exit
fi

BOOKMARKS_FILE=""
HOME=$(env  | grep HOME | grep -oe '[^=]*$');
USE_CHROME=false

# Chrome bookmarks directory
if [ "$(uname)" == "Darwin" ]; then
  BOOKMARKS_FILE="${HOME}/Library/Application Support/Google/Chrome/Default/Bookmarks"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  BOOKMARKS_FILE="${HOME}/.config/google-chrome/Default/Bookmarks"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
  BOOKMARKS_FILE="/${HOME}AppData/Local/Google/Chrome/User Data/Default/Bookmarks"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
  BOOKMARKS_FILE="/${HOME}AppData/Local/Google/Chrome/User Data/Default/Bookmarks"
fi

# if bookmarks file does not exist, use firefox bookmarks
# if [ ! -f "$BOOKMARKS_FILE" ]; then
  USE_CHROME=false
  if [ "$(uname)" == "Darwin" ]; then
    BOOKMARKS_FILE="${HOME}/Library/Application Support/Firefox/Profiles/$(ls ${HOME}/Library/Application\ Support/Firefox/Profiles/ | grep default-release)/places.sqlite"
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    BOOKMARKS_FILE="${HOME}/.mozilla/firefox/$(ls ${HOME}/.mozilla/firefox/ | grep default-release)/places.sqlite"
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    BOOKMARKS_FILE="/${HOME}AppData/Roaming/Mozilla/Firefox/Profiles/$(ls /${HOME}AppData/Roaming/Mozilla/Firefox/Profiles/ | grep default-release)/places.sqlite"
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    BOOKMARKS_FILE="/${HOME}AppData/Roaming/Mozilla/Firefox/Profiles/$(ls /${HOME}AppData/Roaming/Mozilla/Firefox/Profiles/ | grep default-release)/places.sqlite"
  fi
# fi

if [ ! -f "$BOOKMARKS_FILE" ]; then
  echo "Bookmarks file not found. Currently only supports Google Chrome and Firefox."
  exit
fi

if [ "$USE_CHROME" = true ]; then
  bookmarks_data=$(cat "$BOOKMARKS_FILE")
  bookmark_titles_0=$(jq '[.roots.bookmark_bar.children[] | select(.type == "url") | .name]' "$BOOKMARKS_FILE")
  bookmark_titles_1=$(jq '[.roots.bookmark_bar.children[] | select(.children) | .children[] | select(.type == "url") | .name]' "$BOOKMARKS_FILE")
  bookmark_titles_2=$(jq '[.roots.bookmark_bar.children[] | select(.children) | .children[] | select(.children) | .children[] | select(.type == "url") | .name]' "$BOOKMARKS_FILE")
  bookmark_urls_0=$(jq '[.roots.bookmark_bar.children[] | select(.type == "url") | .url]' "$BOOKMARKS_FILE")
  bookmark_urls_1=$(jq '[.roots.bookmark_bar.children[] | select(.children) | .children[] | select(.type == "url") | .url]' "$BOOKMARKS_FILE")
  bookmark_urls_2=$(jq '[.roots.bookmark_bar.children[] | select(.children) | .children[] | select(.children) | .children[] | select(.type == "url") | .url]' "$BOOKMARKS_FILE")
else
  echo "Using Firefox bookmarks"
output_file="bookmarks.json"
temp_bookmarks_file="temp_bookmarks.sqlite"
cp "$BOOKMARKS_FILE" "$temp_bookmarks_file"

echo $BOOKMARKS_FILE
echo $temp_bookmarks_file

sqlite3 "$temp_bookmarks_file" <<EOF > "$output_file"
.headers on
.mode json
.output stdout
SELECT h.url, b.title
FROM moz_places h
JOIN moz_bookmarks b
ON h.id = b.fk;
EOF

echo $output_file

# Print the lists
bookmark_titles_0=($(jq '.[].title' bookmarks.json))
bookmark_urls_0=($(jq '.[].url' bookmarks.json))

# Merge elements between double quotes
merged_titles=()
current_title=""

for title in "${bookmark_titles_0[@]}"; do
  if [[ $title == \"* ]]; then
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

# Print the merged list
# Join array elements with newlines
bookmark_titles_0=$(printf "%s\n" "${merged_titles[@]}")
bookmark_urls_0=$(printf "%s\n" "${bookmark_urls_0[@]}")
echo "Titles: ${bookmark_titles_0[@]}"
echo "URLs: ${bookmark_urls_0[@]}"

find . -name "temp_bookmarks.*" -exec rm {} \;
fi

bookmark_matches="$(echo "$bookmark_titles_0" | grep -o '"[^"]\+"' || echo "$bookmark_titles_0" | grep -o '[^, ]\+')
"
url_matches="$(echo "$bookmark_urls_0" | grep -o '"[^"]\+"' || echo "$bookmark_urls_0" | grep -o '[^, ]\+')
"

# Use sed to remove double quotes and any leading/trailing spaces
bookmark_result=$(echo "$bookmark_matches" | sed 's/"//g; s/^ *//; s/ *$//')
url_result=$(echo "$url_matches" | sed 's/"//g; s/^ *//; s/ *$//')

# # Use fzf for fuzzy searching
selected_title=$(printf "%s\n" "${bookmark_result[@]}" | fzf --preview "open {}" --preview-window=up:0%:wrap)

# Convert the formatted string to an array
SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
IFS=$'\n'      # Change IFS to newline char
bookmark_names=($bookmark_result) # split the string into an array
bookmark_urls=($url_result) # split the string into an array
IFS=$SAVEIFS   # Restore original IFS

# Find the URL corresponding to the selected title
selected_url=""
for i in "${!bookmark_names[@]}"; do
  if [ "${bookmark_names[i]}" = "$selected_title" ]; then
    selected_url="${bookmark_urls[i]}"
    break
  fi
done

# Open the URL in Google Chrome
if [[ -n "$selected_url" ]]; then
  if [ "$(uname)" == "Darwin" ]; then
    open -a "Google Chrome" "$selected_url"
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    google-chrome "$selected_url"
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    start chrome "$selected_url"
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    start chrome "$selected_url"
  fi
fi
