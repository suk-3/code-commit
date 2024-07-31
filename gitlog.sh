#!/bin/bash
# Author: Suhas U Kekuda (SUK)
# This shell script is designed to process a list of repository URLs stored in a file named
# `repo_list.txt`. It iterates over each repository URL, clones the repository if it doesn't exist
# locally, or pulls the latest changes if it already exists.

# Define the input file containing repository URLs
REPO_LIST_FILE="repo_list.txt"

# Define output files
AGGREGATE_CSV_FILE="Commits_data.csv"

truncate -s 0 "$AGGREGATE_CSV_FILE"

# Initialize the aggregate CSV file with headers
echo "Repository,Author,No of Commit,Lines Added,Lines Deleted" > "$AGGREGATE_CSV_FILE"

# # Read each repository URL from the input file
while IFS= read -r REPO_URLS || [ -n "$REPO_URLS" ]; do

    REPO_URL_SRC=(${REPO_URLS//|||/ })
    REPO_URL=${REPO_URL_SRC[0]}
    REPO_BRANCH=${REPO_URL_SRC[1]}
    REPO_BRANCH="${REPO_BRANCH:=main}"

    # Extract the repository name from the URL
    REPO_NAME=$(echo "$REPO_URL" | sed 's/\.git//' | awk -F '/' '{print $NF}')
    echo "Repository name: $REPO_NAME"  # Add debug statement

    # Initialize the detailed CSV file with headers including repo name
    OUTPUT_CSV_FILE="${REPO_NAME}_detailed_commit_data.csv"
    # Clone the repository if it doesn't exist, otherwise pull the latest changes
    if [ ! -d "$REPO_NAME" ]; then
        echo "Cloning repository: $REPO_NAME"  # Add debug statement
        git clone "$REPO_URL"
    else
        echo "Pulling latest changes for repository: $REPO_NAME"  # Add debug statement
        (cd "$REPO_NAME" && git pull)
    fi

    # Change to the repository directory
    cd "$REPO_NAME" || { echo "Failed to enter directory: $REPO_NAME"; exit 1; }

    # Check out the main branch
    git checkout --quiet ${REPO_BRANCH}

    # Fetch commit data and process with git log and awk
    git log --pretty=format:'%n%H,%an,%s' --numstat | gawk -v repo="$REPO_NAME" 'BEGIN { FS="\n"; RS="" }

    {
        # Split first line by comma and extract fields
        split($1, arr, ",")
        id=arr[1]
        author=arr[2]
        message=arr[3]

        # Initialize counters for added and removed lines if author is not in the array
        if (!(author in stats)) {
            stats[author]["commits"]=0
            stats[author]["added"]=0
            stats[author]["removed"]=0
        }

        # Increment commit count for the author
        stats[author]["commits"]++

        # Loop through subsequent lines to calculate totals
        for (i = 2; i <= NF; i++) {
            if ($i != "") {
                split($i, nums, /[^0-9]+/)
                stats[author]["added"] += (nums[1] + 0)
                stats[author]["removed"] += (nums[2] + 0)
            }
        }
    }

    END {
        # Print the combined output for each author
        for (author in stats) {
            printf "%s,%s,%d,%d,%d\n", repo, author, stats[author]["commits"], stats[author]["added"], stats[author]["removed"]
        }
    }' >> "../$OUTPUT_CSV_FILE"

    # Append detailed data to aggregate CSV file
    tail -n +2 "../$OUTPUT_CSV_FILE" >> "../$AGGREGATE_CSV_FILE"
    rm "../$OUTPUT_CSV_FILE"
    # Change back to the original directory
    cd ..
done < "$REPO_LIST_FILE"
