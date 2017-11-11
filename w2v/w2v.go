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

package w2v

import (
	"bufio"
	"encoding/binary"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/opennota/morph"
	"github.com/opennota/pushkin/f32"
)

var posConv = map[string]string{
	"NOUN": "NOUN",
	"VERB": "VERB",
	"INFN": "VERB",
	"GRND": "VERB",
	"PRTF": "VERB",
	"PRTS": "VERB",
	"ADJF": "ADJ",
	"ADJS": "ADJ",
	"ADVB": "ADV",
	"PRED": "ADP",
}

type stringReader interface {
	io.Reader
	ReadString(byte) (string, error)
}

type Model struct {
	vectorSize int
	vectors    []float32
	dictionary []string
	w2v        map[string]uint32
}

func FromReader(r io.Reader) (*Model, error) {
	sr, ok := r.(stringReader)
	if !ok {
		sr = bufio.NewReader(r)
	}
	var dictSize, vectSize int
	if _, err := fmt.Fscanln(sr, &dictSize, &vectSize); err != nil {
		return nil, err
	}
	padding := (16 - (vectSize*4)%16) / 4
	paddedSize := vectSize + padding
	vectors := make([]float32, dictSize*paddedSize)
	dict := make([]string, dictSize)
	w2v := make(map[string]uint32, dictSize)
	for i := 0; i < dictSize; i++ {
		word, err := sr.ReadString(' ')
		if err != nil {
			return nil, err
		}
		word = word[:len(word)-1]

		off := i * paddedSize
		v := vectors[off : off+vectSize]
		if err := binary.Read(sr, binary.LittleEndian, v); err != nil {
			return nil, err
		}
		f32.Norm(v)

		dict[i] = word
		w2v[word] = uint32(off)
	}
	return &Model{
		vectorSize: vectSize,
		vectors:    vectors,
		dictionary: dict,
		w2v:        w2v,
	}, nil
}

func FromFile(filename string) (*Model, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	return FromReader(f)
}

func (m *Model) Size() int {
	return len(m.w2v)
}

func (m *Model) Dictionary() []string {
	return m.dictionary
}

func (m *Model) Vector(token string) []float32 {
	index, ok := m.w2v[token]
	if !ok {
		return nil
	}
	return m.vectors[index : int(index)+m.vectorSize : int(index)+m.vectorSize]
}

func getpos(tag string) string {
	index := strings.IndexAny(tag, ", ")
	if index == -1 {
		return tag
	}
	return tag[:index]
}

func appendUniq(a []string, v string) []string {
	for _, w := range a {
		if v == w {
			return a
		}
	}
	return append(a, v)
}

var yoReplacer = strings.NewReplacer("ё", "е")

func tokenize(words []string) []string {
	var tokens []string
	for _, w := range words {
		if strings.IndexByte(w, '_') != -1 {
			tokens = appendUniq(tokens, yoReplacer.Replace(w))
			continue
		}
		_, norms, tags := morph.Parse(strings.ToLower(w))
		if len(norms) == 0 {
			continue
		}
		for i, tag := range tags {
			pos := posConv[getpos(tag)]
			if pos == "" {
				continue
			}
			tokens = appendUniq(tokens, yoReplacer.Replace(norms[i])+"_"+pos)
		}
	}
	return tokens
}

func (m *Model) Vectorize(words []string) ([]string, []float32) {
	var rv []float32
	tokens := tokenize(words)
	usedTokens := tokens[:0]
	for _, tok := range tokens {
		v := m.Vector(tok)
		if v == nil {
			continue
		}
		if rv == nil {
			rv = make([]float32, m.vectorSize)
		}
		f32.Sum(rv, v)
		usedTokens = append(usedTokens, tok)
	}
	if rv == nil {
		return nil, nil
	}
	f32.Norm(rv)
	return usedTokens, rv
}
