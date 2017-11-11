pushkin [![GoDoc](http://godoc.org/github.com/opennota/pushkin?status.svg)](http://godoc.org/github.com/opennota/pushkin) [![Build Status](https://travis-ci.org/opennota/pushkin.png?branch=master)](https://travis-ci.org/opennota/pushkin)
=======

Search poems and pieces by Alexander Sergeyevich Pushkin with the help of [word2vec](https://en.wikipedia.org/wiki/Word2vec).

![Screencast](/screencast.gif)

## Install

    go get -u github.com/opennota/pushkin

Or download a pre-built version from the [Releases](https://github.com/opennota/pushkin/releases) page.

## Use

Download a word2vec model from [http://rusvectores.org/ru/models](http://rusvectores.org/ru/models/). E.g., ruscorpora. Extract it with gunzip.

Then

    pushkin ruscorpora_1_300_10.bin pushkin.json-stream


## License

GPL v3

