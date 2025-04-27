# Mini-Grep Script (`mygrep.sh`)

A lightweight, mini version of the `grep` command, built using Bash.

## 🚀 Features
- **Show matching lines** from a file
- **Options supported:**
  - `-n` : Show line numbers for each match
  - `-v` : Invert match (show lines that do NOT match)
  - `-vn` / `-nv` : Combine options (order doesn't matter)
  - `--help` : Display usage instructions

## 🛠️ How to Use

1. Make the script executable:
    ```bash
    chmod +x mygrep.sh
    ```

2. Run the script:
    ```bash
    ./mygrep.sh [OPTIONS] search_string filename
    ```

### 📋 Examples:
```bash
./mygrep.sh hello testfile.txt        # Search for 'hello' (case-insensitive)
./mygrep.sh -n hello testfile.txt      # Search with line numbers
./mygrep.sh -vn hello testfile.txt     # Inverted match + line numbers
./mygrep.sh -nv hello testfile.txt     # Inverted match + line numbers
./mygrep.sh --help                     # Show help message
