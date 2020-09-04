#!/bin/bash

files=(
  __mocks__
  src
  .browserslistrc
  .gitignore
  .prettierrc
  babel.config.json
  jest.config.js
  LICENSE
  package.json
  tsconfig.json
  tslint.json
)
authorUsername="kitsune7"
bootstrapRepoName="react-bootstrap"

function prompt() {
  question=${1:-""}
  defaultValue=${2:-""}

  read -r -p "$question" value

  if [[ -z "$value" ]]; then
    echo "$defaultValue"
  else
    echo "$value"
  fi
}

name=$(prompt "What would you like to call the repository (name)? " "new-react-project")
description=$(prompt "What is it (description)? ")
username=$(prompt "What's your GitHub username? " "$authorUsername")
printf 'Okay! New repo, coming right up!\n'
repoPath="../$name"

echo "Creating repository at ../$name"
if [[ -d "$repoPath" ]]; then
  echo "$repoPath already exists. Exiting..."
  exit 1
fi
mkdir "$repoPath"

echo "Copying repository files"
cp -R "${files[@]}" "$repoPath"

echo "Generating README.md"
printf "# %s\n%s\n" "$name" "$description" > "$repoPath/README.md"

echo "Updating package.json"
cd "$repoPath" || return
nameReplacement="s/$bootstrapRepoName/$name/g"
descriptionReplacement="s/\(\"description\": \"\).*\(\",$\)/\1$description\2/g"
usernameReplacement="s/$authorUsername/$username/g"

if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "$nameReplacement" ./package.json
  sed -i '' "$descriptionReplacement" ./package.json
  sed -i '' "$usernameReplacement" ./package.json
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
  sed -i "$nameReplacement" ./package.json
  sed -i "$descriptionReplacement" ./package.json
  sed -i "$usernameReplacement" ./package.json
fi

echo "Initializing git repo"
git init
git add .
git commit -m "Initial commit"

shouldAddRemote=$(prompt "Would you like to immediately add your repository to GitHub (y/n)? " "n")
case ${shouldAddRemote:0:1} in
  y|Y)
    git remote add origin "https://github.com/$username/$name.git"
    git push -u origin master
    echo "You're repository is setup remotely at https://github.com/$username/$name"
  ;;
  *)
    echo "Okay, we'll just keep things local for now. You can add it later if you'd like with the following commands:"
    printf "git remote add origin git@github.com:%s/%s.git\n" "$username" "$name"
    printf "git push -u origin master\n\n"
  ;;
esac

echo "Installing dependencies"
if ! command -v yarn &> /dev/null; then
  npm install --silent
else
  yarn install --silent
fi

echo "You're all setup! Local repository installed in $repoPath"
