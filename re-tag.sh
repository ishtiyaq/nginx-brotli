#!/bin/bash

git tag -d $1
git tag $1
git push origin -d $1
git push origin $1
