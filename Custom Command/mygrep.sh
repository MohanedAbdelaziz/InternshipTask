#!/bin/bash

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS] PATTERN FILE"
    echo "Search for PATTERN in FILE."
    echo ""
    echo "Options:"
    echo "  -n      Show line numbers for each match"
    echo "  -v      Invert the match (print lines that do not match)"
    echo "  --help  Display this help message and exit"
    echo ""
    echo "Example:"
    echo "  $0 hello testfile.txt       # Search for 'hello' in testfile.txt"
    echo "  $0 -n hello testfile.txt    # Show line numbers for matches"
    echo "  $0 -vn hello testfile.txt   # Show line numbers for non-matches"
}

# Initialize variables
show_line_numbers=false
invert_match=false
pattern=""
file=""

# Parse command line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_usage
            exit 0
            ;;
        -[nv]*)
            # Handle combined options like -nv or -vn
            if [[ "$1" == *n* ]]; then
                show_line_numbers=true
            fi
            if [[ "$1" == *v* ]]; then
                invert_match=true
            fi
            shift
            ;;
        -*)
            echo "Error: Unknown option: $1" >&2
            show_usage
            exit 1
            ;;
        *)
            # First non-option argument is the pattern, second is the file
            if [[ -z "$pattern" ]]; then
                pattern="$1"
            elif [[ -z "$file" ]]; then
                file="$1"
            else
                echo "Error: Too many arguments" >&2
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if we have all required arguments
if [[ -z "$pattern" ]]; then
    echo "Error: Missing search pattern" >&2
    show_usage
    exit 1
fi

if [[ -z "$file" ]]; then
    echo "Error: Missing filename" >&2
    show_usage
    exit 1
fi

# Check if the file exists and is readable
if [[ ! -f "$file" ]] || [[ ! -r "$file" ]]; then
    echo "Error: Cannot read file '$file'" >&2
    exit 1
fi

# Process the file line by line
line_number=0
while IFS= read -r line; do
    ((line_number++))
    
    # Check if the line matches the pattern (case-insensitive)
    if echo "$line" | grep -qi "$pattern"; then
        match=true
    else
        match=false
    fi
    
    # Determine whether to print the line based on match and invert flag
    if { $match && ! $invert_match; } || { ! $match && $invert_match; }; then
        if $show_line_numbers; then
            echo "$line_number:$line"
        else
            echo "$line"
        fi
    fi
done < "$file"

exit 0
