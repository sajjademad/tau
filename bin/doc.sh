#!/bin/bash

VERSION=$1


rm -r doc/pages/flutter-sound/api
cd flutter_sound
flutter clean
flutter pub get
dartdoc --pretty-index-json  --output ../doc/pages/flutter-sound/api
cd ..

if [ ! -z "$VERSION" ]; then
        gsed -i  "s/^tau_version:.*/tau_version: $VERSION/"                                     doc/_config.yml
        gsed -i  "s/^\( *version: \).*/\1$VERSION/"                                             doc/_data/sidebars/mydoc_sidebar.yml
fi

echo "Front matter"
for f in $(find doc/pages/flutter-sound/api -name '*.html' )
do
        echo $f
        gsed -i  "1i ---" $f
        gsed -i  "1i ---" $f
done
echo done

git add .
git commit -m "TAU : Version $VERSION"
git push
if [ ! -z "$VERSION" ]; then
        git tag -f $VERSION
        git push --tag -f
fi
