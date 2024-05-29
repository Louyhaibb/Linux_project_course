#!/usr/bin/env bash

# Function to display error messages and exit
error_exit() {
    echo "$1" >&2
    exit 1
}

# Check if an argument is provided
[ -z "$1" ] && error_exit "Please provide a description argument."

# Find the first CSV file in the current directory
csv_file=$(find . -maxdepth 1 -type f -name "*.csv" | head -n 1)
[ -z "$csv_file" ] && error_exit "No CSV file found in this directory."

# Arrays to store CSV data
bug_ids=()
descriptions=()
developers=()
priorities=()
urls=()
branches=()

# Read the CSV file
while IFS=',' read -r bug_id description branch developer priority url; do
    bug_ids+=("$bug_id")
    descriptions+=("$description")
    branches+=("$branch")
    developers+=("$developer")
    priorities+=("$priority")
    urls+=("$url")
done < "$csv_file"  

# Get the current branch name
current_branch=$(git branch --show-current)

# Loop through entries
for ((i = 0; i < ${#bug_ids[@]}; i++)); do
    if [ "$current_branch" == "${branches[i]}" ]; then
        commit_message="BugId: ${bug_ids[i]}
        CurrentDate: $(date +'%Y-%m-%d %H:%M:%S')
        BranchName: ${branches[i]}
        DevName: ${developers[i]}
        Priority: ${priorities[i]}
        ExcelDescription: ${descriptions[i]}
        DevDescription: $1"
        
        # Check if origin remote exists, if not, add it
        if ! git remote | grep -q "^origin$"; then
            git remote add origin "${urls[i]}" || error_exit "Failed to add remote origin."
        fi
        git add . 
        git commit -m "$commit_message"
        # Push changes to remote repository
        git push -u origin "${branches[i]}" || error_exit "Failed to push changes to remote repository."
    fi
done

echo "Script executed successfully."


