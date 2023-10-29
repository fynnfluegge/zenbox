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
if [ "$(uname)" == "Darwin" ]; then
  BOOKMARKS_FILE="${HOME}/Library/Application Support/Google/Chrome/Default/Bookmarks"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  BOOKMARKS_FILE="${HOME}/.config/google-chrome/Default/Bookmarks"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
  BOOKMARKS_FILE="/${HOME}AppData/Local/Google/Chrome/User Data/Default/Bookmarks"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
  BOOKMARKS_FILE="/${HOME}AppData/Local/Google/Chrome/User Data/Default/Bookmarks"
fi

# Read and parse the bookmarks file
bookmarks_data=$(cat "$BOOKMARKS_FILE")
bookmark_titles_0=$(jq '[.roots.bookmark_bar.children[] | select(.type == "url") | .name]' "$BOOKMARKS_FILE")
bookmark_titles_1=$(jq '[.roots.bookmark_bar.children[] | select(.children) | .children[] | select(.type == "url") | .name]' "$BOOKMARKS_FILE")
bookmark_titles_2=$(jq '[.roots.bookmark_bar.children[] | select(.children) | .children[] | select(.children) | .children[] | select(.type == "url") | .name]' "$BOOKMARKS_FILE")
bookmark_urls_0=$(jq '[.roots.bookmark_bar.children[] | select(.type == "url") | .url]' "$BOOKMARKS_FILE")
bookmark_urls_1=$(jq '[.roots.bookmark_bar.children[] | select(.children) | .children[] | select(.type == "url") | .url]' "$BOOKMARKS_FILE")
bookmark_urls_2=$(jq '[.roots.bookmark_bar.children[] | select(.children) | .children[] | select(.children) | .children[] | select(.type == "url") | .url]' "$BOOKMARKS_FILE")

bookmark_matches="$(echo "$bookmark_titles_0" | grep -o '"[^"]\+"' || echo "$bookmark_titles_0" | grep -o '[^, ]\+')
$(echo "$bookmark_titles_1" | grep -o '"[^"]\+"' || echo "$bookmark_titles_1" | grep -o '[^, ]\+')
$(echo "$bookmark_titles_2" | grep -o '"[^"]\+"' || echo "$bookmark_titles_2" | grep -o '[^, ]\+')
"
url_matches="$(echo "$bookmark_urls_0" | grep -o '"[^"]\+"' || echo "$bookmark_urls_0" | grep -o '[^, ]\+')
$(echo "$bookmark_urls_1" | grep -o '"[^"]\+"' || echo "$bookmark_urls_1" | grep -o '[^, ]\+')
$(echo "$bookmark_urls_2" | grep -o '"[^"]\+"' || echo "$bookmark_urls_2" | grep -o '[^, ]\+')
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
