# Infrastructure

This repository houses infrastructure config and release data for badgerodon.com and other apps.

## Commands

Install the app:

    go install

Build the base images:

    (cd images && ./build.sh)

Build all the apps:

    infrastructure build

Deploy them:

    infrastructure deploy

