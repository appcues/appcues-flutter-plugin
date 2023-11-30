#!/bin/sh

# check if `yq` tool is installed.
if ! command -v yq &> /dev/null
then
	echo "yq tool is required, but could not be found."
	echo "Install it via: $ brew install yq"
	exit 1
fi

# check if `gh` tool is installed.
if ! command -v gh &> /dev/null
then
	echo "Github CLI tool is required, but could not be found."
	echo "Install it via: $ brew install gh"
	exit 1
fi

# check if `gh` tool has auth access.
# command will return non-zero if not auth'd.
authd=$(gh auth status -t)
if [[ $? != 0 ]]
then
	echo "ex: $ gh auth login"
	exit 1
fi

# check that we're on the `main` branch
branch=$(git rev-parse --abbrev-ref HEAD)
if [ $branch != 'main' ]
then
	echo "The 'main' must be the current branch to make a release."
	echo "You are currently on: $branch"
	exit 1
fi

if [ -n "$(git status --porcelain)" ]
then
  echo "There are uncommited changes. Please commit and create a pull request or stash them.";
  exit 1
fi

version=$(yq eval .version pubspec.yaml)
echo "Appcues plugin package current version: $version"

# no args, so give usage.
if [ $# -eq 0 ]
then
	echo "Release automation script"
	echo ""
	echo "Usage: $ ./release.sh <version>"
	echo "   ex: $ ./release.sh \"1.0.2\""
	exit 0
fi

newVersion="${1}"
echo "Preparing to release $newVersion..."

versionComparison=$(./scripts/semver.sh $newVersion $version)

if [ $versionComparison != '1' ]
then
	echo "New version must be greater than previous version ($version)."
	exit 1
fi

read -r -p "Are you sure you want to release $newVersion? [y/N] " response
case "$response" in
	[yY][eE][sS]|[yY])
		;;
	*)
		exit 1
		;;
esac

# generate the updated CHANGELOG.md for the repo (Flutter requirement)
changelog="## $newVersion\n"
changelog+=$(git log --pretty=format:"* %s (%h)" $(git describe --tags --abbrev=0 @^)..@ --abbrev=7 | sed '/[🔖]/d')
changelog+="\n"
changelogTempFile=$(mktemp)
echo "$changelog" >> $changelogTempFile
cat CHANGELOG.md >> $changelogTempFile
mv $changelogTempFile CHANGELOG.md

# update pubspec.yaml version.
yq -i e '.version = "'${newVersion}'"' pubspec.yaml

# update example/pubspec.yaml version.
yq -i e '.version = "'${newVersion}'"' example/pubspec.yaml

# ios/appcues_flutter.podspec - version
sed -i '' -e "s/s.version = '$version'/s.version = '$newVersion'/g" ios/appcues_flutter.podspec

# android/build.gradle - version
sed -i '' -e "s/version '$version'/version '$newVersion'/g" android/build.gradle

# commit the version change.
git commit -am "🔖 Update version to $newVersion"
git push

# generate the changelog for the git release update
releaseChangelog=$(git log --pretty=format:"- [%as] %s (%h)" $(git describe --tags --abbrev=0 @^)..@ --abbrev=7 | sed '/[🔧🎬📸✅💡📝]/d')
releaseTempFile=$(mktemp)
echo "$releaseChangelog" >> $releaseTempFile

# gh release will make both the tag and the release itself.
gh release create $newVersion -F $releaseTempFile -t $newVersion

# remove the temp files
rm $releaseTempFile
rm $changelogTempFile

# publish to pub.dev
flutter pub publish