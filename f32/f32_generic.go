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

package f32

import "math"

func Norm(v []float32) {
	if len(v) == 300 {
		Norm300(v)
		return
	}
	var d float32
	for _, x := range v {
		d += x * x
	}
	d = float32(math.Sqrt(float64(d)))
	for i := range v {
		v[i] /= d
	}
}

func Sum(a, b []float32) {
	if len(a) != len(b) {
		panic("slice lengths must be equal!")
	}
	if len(a) == 300 {
		Sum300(a, b)
		return
	}
	for i, x := range b {
		a[i] += x
	}
}

func Dot(a, b []float32) float32 {
	if len(a) != len(b) {
		panic("slice lengths must be equal!")
	}
	if len(a) == 300 {
		return Dot300(a, b)
	}
	var d float32
	for i, x := range a {
		d += x * b[i]
	}
	return d
}