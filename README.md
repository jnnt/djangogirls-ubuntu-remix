# djangogirls-(l)ubuntu-remix
Semi-automated creation of Lubuntu remix ISO with all resources needed to complete the Django Girls tutorial.

**Warning: This is not a user-friendly tool. Use at your own risk. You can break your OS if you are not careful.**


## Goal

A LiveUSB which you can use as a way to deal with failing internet connection and stubborn computers during Django Girls workshops.
This remix could also be an introduction to GNU/Linux OS for workshop participants.

## What does make-dg-remix.sh do?

We start from official Lubuntu ISO, install packages, add some resources and generate a new ISO file to be booted from an USB stick or run on a virtual machine.

## New contents on the ISO

* python3-pip, virtualenv, git and dependencies
* vim, emacs
* Atom, Gedit
* Google Chrome

`/usr/share/djangogirls:`

* Django Girls tutorial and translations in PDFs
* Bootstrap, Lobster font
* wheelhouse (Django 1.8 and 1.9, ipython, ipdb wheels)

## Usage:

I tested this only on a Linux host.
Carefully execute contents of the `make-dg-remix.sh` script by copy-pasting commands to your terminal :]

You need sudo rights on your system, as you'll be making a `chroot` environment.

## TODO

* whoa...
* a pretty wallpaper
* add more flavour to the distro - make a splash, change live session username and hostname (this requires modifying initrd) etc
* consider adding persistent storage
* either remove installation option or work on it
* this a work in progress and I don't know where this project should be going: issues and PRs are very welcome :)
