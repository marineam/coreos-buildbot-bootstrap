#!/bin/bash

set -ex

source /etc/conf.d/buildbot-setup

mkfs.ext4 $BUILDBOT_DEV
mkfs.ext4 $BUILDBOT2_DEV
mkdir -p $BUILDBOT_MNT
mkdir -p $BUILDBOT2_MNT
mount -t ext4 -o noatime,data=writeback $BUILDBOT_DEV $BUILDBOT_MNT
mount -t ext4 -o noatime,data=writeback $BUILDBOT2_DEV $BUILDBOT2_MNT
mkdir -p $BUILDBOT_MNT/{master,slave}
mkdir -p $BUILDBOT2_MNT/slave

buildbot create-master $BUILDBOT_MNT/master
buildslave create-slave --umask=022 \
    $BUILDBOT_MNT/slave localhost localhost localhost
buildslave create-slave --umask=022 \
    $BUILDBOT2_MNT/slave localhost localhost2 localhost2

ln -s /etc/buildbot-master.cfg $BUILDBOT_MNT/master/master.cfg
cp /etc/buildbot-boto $BUILDBOT_MNT/slave/.boto
cp /etc/buildbot-boto-key.p12 $BUILDBOT_MNT/slave/.boto-key.p12
mkdir -p $BUILDBOT_MNT/slave/.ssh
cp /etc/buildbot-ssh-key $BUILDBOT_MNT/slave/.ssh/id_rsa
chown -R buildbot:buildbot $BUILDBOT_MNT
chown -R buildbot:buildbot $BUILDBOT2_MNT
su --login --shell /bin/bash \
    --command "gpg --import /etc/buildbot-gpg-*.asc" buildbot
