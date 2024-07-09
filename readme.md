# Git Repository Report Script

This shell script is designed to process a list of repository URLs stored in a file named `repo_list.txt`. It iterates over each repository URL, clones the repository if it doesn't exist locally, or pulls the latest changes if it already exists, and generates a report in CSV format.

## Prerequisites

Before running the script, ensure you have the following installed:

- **Git CLI**: This is required to clone and pull repositories.
- **Homebrew**: A package manager for macOS that makes it easy to install software.
- **Access to the repositories**: Ensure you have the necessary permissions to access the repositories you want to generate a report for.

## Execution Steps

### 1. Set Execute Permission

First, you need to give execute permissions to the script. Open your terminal and run:

```sh
chmod 755 gitlog.sh
```

### 2. Running on macOS

#### Install gawk

The script requires `gawk` (GNU AWK) for processing data. You can install it using Homebrew:

```sh
brew install gawk
```

If you encounter any issues with macOS quarantine settings, remove the quarantine attribute:

```sh
xattr -d com.apple.quarantine gitlog.sh
```

#### Optional: Change Default Shell to Bash

If you face issues with the macOS default ksh console, you can change your default shell to bash:

```sh
chsh -s /bin/bash
```

## Script Details

### Explanation

1. **Check for `repo_list.txt`**: The script starts by checking if `repo_list.txt` exists. If not, it prints an error message and exits.

2. **Create or Clear `Commits_data.csv`**: It creates or clears the `Commits_data.csv` file to store the status of each repository.

3. **Iterate Over Repository URLs**: It reads each line from `repo_list.txt`:
   - **Extract Repo Name**: Extracts the repository name from the URL.
   - **Check if Repo Exists Locally**: Checks if the repository already exists locally:
     - If it exists, it navigates to the repository directory, pulls the latest changes, navigates back, and logs the update status.
     - If it doesn't exist, it clones the repository and logs the clone status.

4. **Completion Message**: Finally, it prints a message indicating that the report has been generated in `Commits_data.csv`.

## Additional Notes

- Ensure `repo_list.txt` is in the same directory as `gitlog.sh` or provide the correct path.
- Make sure you have the necessary permissions to clone and pull from the repositories listed in `repo_list.txt`.
- If you encounter an issue with file formatting to Unix for your code / repolist, you can resolve it by running the following command:

```sh
vim -c "wq ++ff=unix" repo_list.txt
vim -c "wq ++ff=unix" gitlog.sh
```



