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

// func Dot300(a, b []float32) float32
TEXT ·Dot300(SB), 0, $0-8
	MOVQ a+0(FP), SI
	MOVQ b+24(FP), DI

	XORQ AX, AX
	PXOR X0, X0
	MOVQ DI, DX
	ANDQ $3, DX
	JNZ  unaligned

aligned4:
	MOVQ DI, DX
	ANDQ $15, DX
	JZ   aligned16
	CMPQ DX, $12
	JE   trim1
	CMPQ DX, $8
	JE   trim2

trim3:
	MOVSS (SI)(AX*4), X1
	MULSS (DI)(AX*4), X1
	INCQ  AX
	ADDSS X1, X0

trim2:
	MOVSS (SI)(AX*4), X2
	MULSS (DI)(AX*4), X2
	INCQ  AX
	ADDSS X2, X0

trim1:
	MOVSS (SI)(AX*4), X3
	MULSS (DI)(AX*4), X3
	INCQ  AX
	ADDSS X3, X0

aligned16:
	MOVQ $10, CX

loop_aligned16:
	MOVUPS (SI)(AX*4), X1
	MOVUPS 16(SI)(AX*4), X2
	MOVUPS 32(SI)(AX*4), X3
	MOVUPS 48(SI)(AX*4), X4
	MOVUPS 64(SI)(AX*4), X5
	MOVUPS 80(SI)(AX*4), X6
	MOVUPS 96(SI)(AX*4), X7
	MULPS  (DI)(AX*4), X1
	MULPS  16(DI)(AX*4), X2
	MULPS  32(DI)(AX*4), X3
	MULPS  48(DI)(AX*4), X4
	MULPS  64(DI)(AX*4), X5
	MULPS  80(DI)(AX*4), X6
	MULPS  96(DI)(AX*4), X7
	ADDPS  X1, X2
	ADDPS  X3, X4
	ADDPS  X5, X6
	ADDPS  X7, X0
	ADDPS  X2, X4
	ADDPS  X6, X0
	ADDQ   $28, AX
	ADDPS  X4, X0
	DECQ   CX
	JNZ    loop_aligned16

	MOVUPS (SI)(AX*4), X1
	MOVUPS 16(SI)(AX*4), X2
	MOVUPS 32(SI)(AX*4), X3
	MOVUPS 48(SI)(AX*4), X4
	MULPS  (DI)(AX*4), X1
	MULPS  16(DI)(AX*4), X2
	MULPS  32(DI)(AX*4), X3
	MULPS  48(DI)(AX*4), X4
	ADDPS  X1, X2
	ADDPS  X3, X4
	ADDPS  X2, X0
	ADDQ   $16, AX
	ADDPS  X4, X0

	TESTQ DX, DX
	JE    tail4
	CMPQ  DX, $4
	JE    tail1
	CMPQ  DX, $8
	JE    tail2

tail3:
	MOVSS (SI)(AX*4), X1
	MULSS (DI)(AX*4), X1
	INCQ  AX
	ADDSS X1, X0

tail2:
	MOVSS (SI)(AX*4), X2
	MULSS (DI)(AX*4), X2
	INCQ  AX
	ADDSS X2, X0

tail1:
	MOVSS (SI)(AX*4), X3
	MULSS (DI)(AX*4), X3
	ADDSS X3, X0
	JMP   final

tail4:
	MOVUPS (SI)(AX*4), X1
	MULPS  (DI)(AX*4), X1
	ADDPS  X1, X0

final:
	MOVSHDUP X0, X1
	ADDPS    X1, X0
	MOVHLPS  X0, X1
	ADDSS    X1, X0

	// alternative 1
	// HADDPS X0, X0
	// HADDPS X0, X0

	// alternative 2
	// MOVAPS X0, X1
	// MOVHLPS X0, X1
	// ADDPS X1, X0
	// MOVAPS X0, X2
	// SHUFPS $245, X0, X2
	// ADDSS X2, X0

	MOVSS X0, result+48(FP)

	RET

unaligned:
	MOVQ $42, CX

loop_unaligned:
	MOVSS (SI)(AX*4), X1
	MOVSS 4(SI)(AX*4), X2
	MOVSS 8(SI)(AX*4), X3
	MOVSS 12(SI)(AX*4), X4
	MOVSS 16(SI)(AX*4), X5
	MOVSS 20(SI)(AX*4), X6
	MOVSS 24(SI)(AX*4), X7
	MULSS (DI)(AX*4), X1
	MULSS 4(DI)(AX*4), X2
	MULSS 8(DI)(AX*4), X3
	MULSS 12(DI)(AX*4), X4
	MULSS 16(DI)(AX*4), X5
	MULSS 20(DI)(AX*4), X6
	MULSS 24(DI)(AX*4), X7
	ADDSS X1, X2
	ADDSS X3, X4
	ADDSS X5, X6
	ADDSS X7, X0
	ADDSS X2, X4
	ADDSS X6, X0
	ADDQ  $7, AX
	ADDSS X4, X0
	DECQ  CX
	JNZ   loop_unaligned

	MOVSS (SI)(AX*4), X1
	MOVSS 4(SI)(AX*4), X2
	MOVSS 8(SI)(AX*4), X3
	MOVSS 12(SI)(AX*4), X4
	MOVSS 16(SI)(AX*4), X5
	MOVSS 20(SI)(AX*4), X6
	MULSS (DI)(AX*4), X1
	MULSS 4(DI)(AX*4), X2
	MULSS 8(DI)(AX*4), X3
	MULSS 12(DI)(AX*4), X4
	MULSS 16(DI)(AX*4), X5
	MULSS 20(DI)(AX*4), X6
	ADDSS X1, X2
	ADDSS X3, X4
	ADDSS X5, X6
	ADDSS X2, X4
	ADDSS X6, X0
	ADDSS X4, X0
	JMP   final
