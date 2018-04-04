# GetGithubRepos
Gets a list of github repos by searching for the specified key words on github.com
The results are written to a txt file by default

## Usage

```
./get_github_repos.sh <keywords>
```

##Arguments

keywords - keywords to search for 

## Requirements

curl - for downloading the search page locally

## Example

To search for all github with the word 'google' in the author or repo name
```
./get_github_repos.sh google
```
