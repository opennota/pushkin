// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
// Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  If not, see <http://www.gnu.org/licenses/>.

//go:generate esc -o data.go -pkg morph data.gob

// Package morph provides a simple morphological analyzer for Russian language,
// using the compiled dictionaries from pymorphy2.
package morph

import (
	"bytes"
	"encoding/binary"
	"encoding/gob"
	"strings"
)

var (
	prefixes  []string
	suffixes  []string
	tags      []string
	paradigms [][]uint16
	d         *dawg
)

// Parse analyzes the word and returns three slices of the same length.
// Each triple (words[i], norms[i], tags[i]) represents an analysis, where:
// - words[i] is the word with the letter ё fixed;
// - norms[i] is the normal form of the word;
// - tags[i] is the grammatical tag, consisting of the word's grammemes.
func Parse(word string) (words []string, norms []string, tags []string) {
	for _, it := range d.similarItems(word) {
		for _, v := range it.values {
			paraNum := int(binary.BigEndian.Uint16(v))
			para := paradigms[paraNum]
			index := int(binary.BigEndian.Uint16(v[2:]))

			prefix, suffix, tag := prefixSuffixTag(para, index)

			norm := it.key
			if index != 0 {
				stem := strings.TrimPrefix(norm, prefix)
				stem = strings.TrimSuffix(stem, suffix)
				pr, su, _ := prefixSuffixTag(para, 0)
				norm = pr + stem + su
			}

			words = append(words, it.key)
			norms = append(norms, norm)
			tags = append(tags, tag)
		}
	}
	return words, norms, tags
}

func init() {
	data, _ := FSByte(false, "/data.gob")
	if err := gob.NewDecoder(bytes.NewReader(data)).Decode(
		&struct {
			Prefixes  *[]string
			Suffixes  *[]string
			Tags      *[]string
			Paradigms *[][]uint16
			DAWG      **dawg
		}{
			&prefixes,
			&suffixes,
			&tags,
			&paradigms,
			&d,
		}); err != nil {
		panic(err)
	}
}

func prefixSuffixTag(para []uint16, i int) (string, string, string) {
	n := len(para) / 3
	suffixIndex := para[i]
	tagIndex := para[i+n]
	prefixIndex := para[i+2*n]
	return prefixes[prefixIndex], suffixes[suffixIndex], tags[tagIndex]
}
