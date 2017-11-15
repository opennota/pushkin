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

package main

import (
	"encoding/json"
	"flag"
	"html/template"
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"regexp"
	"sort"
	"strings"
	"time"

	"github.com/opennota/pushkin/f32"
	"github.com/opennota/pushkin/w2v"
)

var (
	addr = flag.String("http", "127.0.0.1:8000", "HTTP service address")
	n    = flag.Int("n", 10, "Number of poems to show")

	rWord = regexp.MustCompile(`(?i)[а-яё]+(?:-[а-яё]+)?`)

	indexTmpl = template.Must(template.New("").Parse(indexHTML))

	w2vModel *w2v.Model
	poems    []Poem
)

type Poem struct {
	Source string
	Text   []string
	vector []float32
}

func appendUniq(a []string, v string) []string {
	for _, x := range a {
		if x == v {
			return a
		}
	}
	return append(a, v)
}

func extractWords(ss []string) []string {
	var result []string
	for _, s := range ss {
		words := rWord.FindAllString(s, -1)
		for _, w := range words {
			w = strings.ToLower(w)
			result = appendUniq(result, w)
		}
	}
	return result
}

func loadPoems(fn string, model *w2v.Model) ([]Poem, error) {
	f, err := os.Open(fn)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	var poems []Poem
	d := json.NewDecoder(f)
	for {
		var poem Poem
		if err := d.Decode(&poem); err != nil {
			if err == io.EOF {
				break
			}
			return nil, err
		}

		_, poem.vector = model.Vectorize(extractWords(poem.Text))
		if poem.vector == nil {
			continue
		}

		poems = append(poems, poem)
	}
	return poems, nil
}

func logRequest(r *http.Request) {
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		host = r.RemoteAddr
	}
	log.Println(host, r.Method, r.URL, r.Referer(), r.UserAgent())
}

func index(w http.ResponseWriter, r *http.Request) {
	logRequest(r)

	q := r.FormValue("query")
	if q == "" {
		if err := indexTmpl.Execute(w, nil); err != nil {
			log.Print(err)
		}
		return
	}

	t, v := w2vModel.Vectorize(strings.Split(q, " "))
	if v == nil {
		if err := indexTmpl.Execute(w, struct {
			Query string
			Error string
		}{q, "Couldn't vectorize the query!"}); err != nil {
			log.Print(err)
		}
		return
	}

	start := time.Now()
	type scoredPoem struct {
		poemIndex int
		score     float32
	}
	scored := make([]scoredPoem, len(poems))
	for i, p := range poems {
		dp := f32.Dot(v, p.vector)
		scored[i] = scoredPoem{i, dp}
	}
	sort.Slice(scored, func(i, j int) bool {
		return scored[i].score > scored[j].score
	})

	type result struct {
		Source string
		Text   []string
		Score  float32
	}
	var results []result
	for i := 0; i < *n; i++ {
		n := scored[i].poemIndex
		results = append(results, result{
			Source: poems[n].Source,
			Text:   poems[n].Text,
			Score:  scored[i].score,
		})
	}

	if err := indexTmpl.Execute(w, struct {
		Query      string
		Error      string
		SearchTime time.Duration
		Tokens     []string
		Results    []result
	}{
		q,
		"",
		time.Since(start),
		t,
		results,
	}); err != nil {
		log.Print(err)
	}
}

func main() {
	flag.Parse()
	if flag.NArg() != 2 {
		log.Fatal("want two arguments!")
	}

	start := time.Now()
	var err error
	w2vModel, err = w2v.FromFile(flag.Arg(0))
	if err != nil {
		log.Fatalf("couldn't load word2vec model: %v", err)
	}
	log.Printf("model loaded in %v\n", time.Since(start))

	start = time.Now()
	poems, err = loadPoems(flag.Arg(1), w2vModel)
	if err != nil {
		log.Fatalf("couldn't load poems: %v", err)
	}
	log.Printf("poems loaded in %v\n", time.Since(start))

	log.Println("listening on", *addr)
	http.HandleFunc("/", index)
	log.Fatal(http.ListenAndServe(*addr, nil))
}

var indexHTML = `
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta charset="utf-8">
    <title>Pushkin</title>
    <style>
      #content { width: 70%; margin: auto; }
      #info { margin-top: 5px; }
      #info, .poem-info, .rvb-link { font-size: x-small; }
      .poem { margin-top: 20px; margin-bottom: 20px; padding-left: 10px; }
      .poem:nth-child(odd) { background-color: #eee; }
      .poem-info { color: grey; margin-left: -10px; }
      a.rvb-link, a.tok-link { color: grey; }
      .error { color: red; margin-top: 10px; }
      a.tok-link { text-decoration-style: dotted; }
      .tok-link:not(:last-child):after { content: ","; }
    </style>
  </head>
<body>
  <div id="content">
    <div id="search-form">
      <form method="GET" action="/">
        <input type="text" name="query" value="{{ .Query }}" autofocus></input>
        <input type="submit" value="Search"></input>
      </form>
    </div>
    {{ if . }}
      {{ if .Error }}
        <div class="error">
          Error: {{ .Error }}
        </div>
      {{ else }}
        <div id="info">
          Search took {{ .SearchTime }}.
          Tokens:
          {{ range .Tokens }}
            <a class="tok-link" href="/?query={{ . }}">{{ . }}</a>
          {{ end }}
        </div>
        <div id="results">
          {{ range .Results }}
            <div class="poem">
              {{ range .Text }}
                {{ . }}<br>
              {{ end }}
              <div class="poem-info">
                Score:
                  {{ .Score }}
                Link:
                  <a class="rvb-link" href="http://rvb.ru/pushkin/{{ .Source }}.htm">
                    http://rvb.ru/pushkin/{{ .Source }}.htm
                  </a>
              </div>
            </div>
          {{ end }}
        </div>
      {{ end }}
    {{ end }}
  </div>
</body>
</html>`
