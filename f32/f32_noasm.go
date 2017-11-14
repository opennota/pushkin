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

// +build !amd64 noasm

package f32

import "math"

func norm300(v []float32) {
	var d float32
	for _, x := range v {
		d += x * x
	}
	d = float32(math.Sqrt(float64(d)))
	for i := range v {
		v[i] /= d
	}
}

func sum300(a, b []float32) {
	for i, x := range b {
		a[i] += x
	}
}

func dot300(a, b []float32) float32 {
	var d float32
	for i, x := range a {
		d += x * b[i]
	}
	return d
}
