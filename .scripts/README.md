# README

## fzfbookmarks.sh
✨ Fuzzy search and open your Chrome/Firefox bookmarks from cli:

<img width="797" alt="Screenshot 2023-11-10 at 17 06 06" src="https://github.com/fynnfluegge/mydotfiles/assets/16321871/29eb5b87-580c-42b9-a6d2-970c4544f7c9">

#### ⚙️ Prerequisites
Make sure `jq` and `fzf` is installed:
```bash
brew install jq fzf
```

#### 🔧 Make script executable
Save `fzfbookmarks.sh` do a desired location, create an alias in `.zshrc`, e.g. `alias fb=$HOME/.scripts/fzfbookmarks.sh`
and run the following command to grant the script execution rights:
```bash
chmod +x $HOME/.scripts/fzfbookmarks.sh
```
