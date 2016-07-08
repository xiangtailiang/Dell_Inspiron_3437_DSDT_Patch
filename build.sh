#!/bin/bash

BUILDDIR=./build

IASLFLAGS=-vw 2095 -vw 2146
IASL=`pwd`/tools/iasl

rm -rf $BUILDDIR/*.aml
$IASL $IASLFLAGS -p  $BUILDDIR/SSDT-HACK.aml ./SSDT-HACK.dsl