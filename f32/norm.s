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

// +build amd64,!noasm

#include "textflag.h"

DATA ·ones+0(SB)/4, $0x3f800000
DATA ·ones+4(SB)/4, $0x3f800000
DATA ·ones+8(SB)/4, $0x3f800000
DATA ·ones+12(SB)/4, $0x3f800000

GLOBL ·ones+0(SB), RODATA, $16

// func Norm300(v []float32)
TEXT ·Norm300(SB), 0, $0-8
	MOVQ v+0(FP), SI

	XORQ AX, AX
	PXOR X0, X0
	MOVQ $12, CX

loop_24:
	MOVUPS (SI)(AX*4), X1
	MOVUPS 16(SI)(AX*4), X2
	MOVUPS 32(SI)(AX*4), X3
	MOVUPS 48(SI)(AX*4), X4
	MOVUPS 64(SI)(AX*4), X5
	MOVUPS 80(SI)(AX*4), X6
	MULPS  X1, X1
	MULPS  X2, X2
	MULPS  X3, X3
	MULPS  X4, X4
	MULPS  X5, X5
	MULPS  X6, X6
	ADDPS  X1, X2
	ADDPS  X3, X4
	ADDPS  X5, X6
	ADDPS  X2, X4
	ADDPS  X6, X0
	ADDQ   $24, AX
	ADDPS  X4, X0
	DECQ   CX
	JNZ    loop_24

	MOVUPS (SI)(AX*4), X1
	MOVUPS 16(SI)(AX*4), X2
	MOVUPS 32(SI)(AX*4), X3
	MULPS  X1, X1
	MULPS  X2, X2
	MULPS  X3, X3

	ADDPS X1, X2
	ADDPS X3, X0
	ADDQ  $12, AX
	ADDPS X2, X0

	HADDPS X0, X0
	HADDPS X0, X0

	RSQRTPS X0, X0

	// precise (but slower) alternative
	// SQRTPS X0, X0
	// MOVUPS ·ones+0(SB), X1
	// DIVPS X0, X1
	// MOVAPS X1, X0

	XORQ AX, AX
	MOVQ $12, CX

loop_24_2:
	MOVUPS (SI)(AX*4), X1
	MOVUPS 16(SI)(AX*4), X2
	MOVUPS 32(SI)(AX*4), X3
	MOVUPS 48(SI)(AX*4), X4
	MOVUPS 64(SI)(AX*4), X5
	MOVUPS 80(SI)(AX*4), X6
	MULPS  X0, X1
	MULPS  X0, X2
	MULPS  X0, X3
	MULPS  X0, X4
	MULPS  X0, X5
	MULPS  X0, X6
	MOVUPS X1, (SI)(AX*4)
	MOVUPS X2, 16(SI)(AX*4)
	MOVUPS X3, 32(SI)(AX*4)
	MOVUPS X4, 48(SI)(AX*4)
	MOVUPS X5, 64(SI)(AX*4)
	MOVUPS X6, 80(SI)(AX*4)
	ADDQ   $24, AX
	DECQ   CX
	JNZ    loop_24_2

	MOVUPS (SI)(AX*4), X1
	MOVUPS 16(SI)(AX*4), X2
	MOVUPS 32(SI)(AX*4), X3
	MULPS  X0, X1
	MULPS  X0, X2
	MULPS  X0, X3
	MOVUPS X1, (SI)(AX*4)
	MOVUPS X2, 16(SI)(AX*4)
	MOVUPS X3, 32(SI)(AX*4)

	RET

