# replace placeholders
sed -i '' -e "s/APPCUES_ACCOUNT_ID/$1/g" ../../lib/main.dart
sed -i '' -e "s/APPCUES_APPLICATION_ID/$2/g" ../../lib/main.dart
sed -i '' -e "s/APPCUES_APPLICATION_ID/$2/g" ../Runner/Info.plist
