#!/bin/bash

set -ex

source /etc/conf.d/buildbot-setup

mkfs.ext4 $BUILDBOT_DEV
mkdir -p $BUILDBOT_MNT
mount -t ext4 $BUILDBOT_DEV $BUILDBOT_MNT
mkdir -p $BUILDBOT_MNT/{master,slave}

buildbot create-master $BUILDBOT_MNT/master
buildslave create-slave --umask=022 \
    $BUILDBOT_MNT/slave localhost localhost localhost

ln -s /etc/buildbot-master.cfg $BUILDBOT_MNT/master/master.cfg
cp /etc/buildbot-boto $BUILDBOT_MNT/slave/.boto
cp /etc/buildbot-boto-key.p12 $BUILDBOT_MNT/slave/.boto-key.p12
chown -R buildbot:buildbot $BUILDBOT_MNT
