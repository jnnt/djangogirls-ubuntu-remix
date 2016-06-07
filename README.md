# djangogirls-(l)ubuntu-remix
Semi-automated creation of Lubuntu remix ISO with all resources needed to complete the Django Girls tutorial.

**Warning: This is not a user-friendly tool. Use at your own risk. You can break your OS if you are not careful.**


## Goal

A LiveUSB which you can use as a way to deal with failing internet connection and stubborn computers during Django Girls workshops.
This remix could also be an introduction to GNU/Linux OS for workshop participants.

## What does make-dg-remix.sh do?

We start from official Lubuntu ISO, install packages, add some resources and generate a new ISO file to be booted from an USB stick or run on a virtual machine.

## New contents

* python3-pip, virtualenv, git and dependencies
* vim, emacs
* Atom, Gedit
* Google Chrome

`/usr/share/djangogirls:`

* Django Girls tutorial and translations in PDFs
* Bootstrap, Lobster font
* wheelhouse (Django 1.8 and 1.9, ipython, ipdb wheels)

## TODO
