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

// func Sum300(a, b []float32)
TEXT ·Sum300(SB), 0, $0-8
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
	ADDSS (DI)(AX*4), X1
	MOVSS X1, (SI)(AX*4)
	INCQ  AX

trim2:
	MOVSS (SI)(AX*4), X2
	ADDSS (DI)(AX*4), X2
	MOVSS X2, (SI)(AX*4)
	INCQ  AX

trim1:
	MOVSS (SI)(AX*4), X3
	ADDSS (DI)(AX*4), X3
	MOVSS X3, (SI)(AX*4)
	INCQ  AX

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
	ADDPS  (DI)(AX*4), X1
	ADDPS  16(DI)(AX*4), X2
	ADDPS  32(DI)(AX*4), X3
	ADDPS  48(DI)(AX*4), X4
	ADDPS  64(DI)(AX*4), X5
	ADDPS  80(DI)(AX*4), X6
	ADDPS  96(DI)(AX*4), X7
	MOVUPS X1, (SI)(AX*4)
	MOVUPS X2, 16(SI)(AX*4)
	MOVUPS X3, 32(SI)(AX*4)
	MOVUPS X4, 48(SI)(AX*4)
	MOVUPS X5, 64(SI)(AX*4)
	MOVUPS X6, 80(SI)(AX*4)
	MOVUPS X7, 96(SI)(AX*4)
	ADDQ   $28, AX
	DECQ   CX
	JNZ    loop_aligned16

	MOVUPS (SI)(AX*4), X1
	MOVUPS 16(SI)(AX*4), X2
	MOVUPS 32(SI)(AX*4), X3
	MOVUPS 48(SI)(AX*4), X4
	ADDPS  (DI)(AX*4), X1
	ADDPS  16(DI)(AX*4), X2
	ADDPS  32(DI)(AX*4), X3
	ADDPS  48(DI)(AX*4), X4
	MOVUPS X1, (SI)(AX*4)
	MOVUPS X2, 16(SI)(AX*4)
	MOVUPS X3, 32(SI)(AX*4)
	MOVUPS X4, 48(SI)(AX*4)
	ADDQ   $16, AX

	TESTQ DX, DX
	JE    tail4
	CMPQ  DX, $4
	JE    tail1
	CMPQ  DX, $8
	JE    tail2

tail3:
	MOVSS (SI)(AX*4), X1
	ADDSS (DI)(AX*4), X1
	MOVSS X1, (SI)(AX*4)
	INCQ  AX

tail2:
	MOVSS (SI)(AX*4), X2
	ADDSS (DI)(AX*4), X2
	MOVSS X2, (SI)(AX*4)
	INCQ  AX

tail1:
	MOVSS (SI)(AX*4), X3
	ADDSS (DI)(AX*4), X3
	MOVSS X3, (SI)(AX*4)
	JMP   final

tail4:
	MOVUPS (SI)(AX*4), X5
	ADDPS  (DI)(AX*4), X5
	MOVUPS X5, (SI)(AX*4)

final:
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
	ADDSS (DI)(AX*4), X1
	ADDSS 4(DI)(AX*4), X2
	ADDSS 8(DI)(AX*4), X3
	ADDSS 12(DI)(AX*4), X4
	ADDSS 16(DI)(AX*4), X5
	ADDSS 20(DI)(AX*4), X6
	ADDSS 24(DI)(AX*4), X7
	MOVSS X1, (SI)(AX*4)
	MOVSS X2, 4(SI)(AX*4)
	MOVSS X3, 8(SI)(AX*4)
	MOVSS X4, 12(SI)(AX*4)
	MOVSS X5, 16(SI)(AX*4)
	MOVSS X6, 20(SI)(AX*4)
	MOVSS X7, 24(SI)(AX*4)
	ADDQ  $7, AX
	DECQ  CX
	JNZ   loop_unaligned

	MOVSS (SI)(AX*4), X1
	MOVSS 4(SI)(AX*4), X2
	MOVSS 8(SI)(AX*4), X3
	MOVSS 12(SI)(AX*4), X4
	MOVSS 16(SI)(AX*4), X5
	MOVSS 20(SI)(AX*4), X6
	ADDSS (DI)(AX*4), X1
	ADDSS 4(DI)(AX*4), X2
	ADDSS 8(DI)(AX*4), X3
	ADDSS 12(DI)(AX*4), X4
	ADDSS 16(DI)(AX*4), X5
	ADDSS 20(DI)(AX*4), X6
	MOVSS X1, (SI)(AX*4)
	MOVSS X2, 4(SI)(AX*4)
	MOVSS X3, 8(SI)(AX*4)
	MOVSS X4, 12(SI)(AX*4)
	MOVSS X5, 16(SI)(AX*4)
	MOVSS X6, 20(SI)(AX*4)

	JMP final
