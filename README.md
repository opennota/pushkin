pushkin [![License](http://img.shields.io/:license-gpl3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0.html) [![GoDoc](http://godoc.org/github.com/opennota/pushkin?status.svg)](http://godoc.org/github.com/opennota/pushkin) [![Build Status](https://travis-ci.org/opennota/pushkin.png?branch=master)](https://travis-ci.org/opennota/pushkin)
=======

Search poems and pieces by Alexander Sergeyevich Pushkin.

![Screencast](/screencast.gif)

## Install

    go get -u github.com/opennota/pushkin

## Use

Download a word2vec model from [http://rusvectores.org/ru/models/](http://rusvectores.org/ru/models/). E.g., ruscorpora. Extract it with gunzip.

Then

    pushkin ruscorpora_1_300_10.bin pushkin.json-stream

