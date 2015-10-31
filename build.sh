#!/bin/bash

# change with the erlc path of your current ejabberd installation
: ${EJBR_PATH:='/opt/ejabberd-15.04'}
: ${EJBR_VERSION:='15.04'}

$EJBR_PATH/bin/erlc -DNO_EXT_LIB -DLAGER -I $EJBR_PATH/lib/ejabberd-$EJBR_VERSION/include/ -o ebin/ src/*
