# Firestore rules tests

These tests run `firestore.rules` (at the repo root) against the Firestore
emulator. They check one or more allowed and blocked cases for every
collection, plus the order queries the app runs. Rules are not filters, so a
query the rules don't allow fails for everyone.

## Run them

You need Node 20+, the Firebase CLI (`npm i -g firebase-tools`) and Java 21
or newer. The JDK that comes with Android Studio works:

```sh
cd firestore_rules
npm install
# Git Bash; only needed if `java -version` is older than 21
export JAVA_HOME="/c/Program Files/Android/Android Studio/jbr"
export PATH="$JAVA_HOME/bin:$PATH"
npm test
```

`npm test` starts the emulator, runs every file in `test/`, then stops it.
Nothing touches the real `sokosafi-b978a` project.

The `PERMISSION_DENIED` lines in the output are expected: they come from
the tests that check a request is blocked.
