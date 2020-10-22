;extern double single_partial_derivative(double (*obj_f)(double x[]),int i, double x[], double h);
;extern double approx_partial_derivative(double (*obj_f)(double x[]), int i, double x[]);
.MODEL SMALL
.386
.387
.DATA
RES DQ ?
X 	DQ ?
TWO DQ 2
num DQ 104576
h 	DQ ?
fd1 DQ ?
fd2 DQ ?
.CODE
_single_partial_derivative PROC NEAR
PUBLIC _single_partial_derivative
	PUSH BP			
	MOV BP,SP						;set bp to use as pointer on stack
	PUSH SI							;save SI 
	MOV SI,[BP+8]					;set si to point on x array
	MOV AX,8						
	MUL WORD PTR [BP+6]				;get the index of our Xi
	MOV BX,AX						;bx=index of Xi
	FLD QWORD PTR [SI+BX]			;ST[0]=Xi
	FST X 							;save value of Xi
	FLD QWORD PTR [BP+16]			;ST[0]=h ST[1]=Xi
	FSUB							;ST[0]=Xi-h
	FSTP QWORD PTR [SI+BX]			;Xi=Xi-h
	PUSH BX							;save bx value
	PUSH SI							;save si value
	CALL [BP+4]						;call to f
	POP SI							;restore si
	POP BX							;restore bx
	FSTP RES						;save the return value from f and empty stack
	FLD QWORD PTR [SI+BX]			;ST[0]=Xi-h
	FADD QWORD PTR[BP+16]		    ;ST[0]=Xi
	FADD QWORD PTR[BP+16]			;ST[0]=Xi+h	
	FSTP QWORD PTR [SI+BX]			;Xi=Xi+h	
	PUSH BX							;save bx value
	PUSH SI							;save si value
	CALL [BP+4]						;call to f
	POP SI							;restore si
	POP BX							;restore bx
	FLD QWORD PTR RES				;ST[0]=RES ST[1]=return from f
	FSUB							;ST[0]=ST[1]-ST[0]
	FLD QWORD PTR [BP+16]			;ST[0]=h ST[1]=ST[1]-ST[0]
	FILD QWORD PTR TWO				;ST[0]=2 ST[1]=h ST[2]=ST[1]-ST[0]
	FMUL 							;ST[0]=2h ST[1]=ST[1]-ST[0]
	FDIV 							;ST[0]=(ST[1]-ST[0])/2h 
	FLD QWORD PTR X					;ST[0]=X ST[1]=(ST[1]-ST[0])/2h 
	FSTP QWORD PTR [SI+BX]			;restore value of Xi
	POP SI							;restore registers
	POP BP
RET
_single_partial_derivative ENDP

_approx_partial_derivative PROC NEAR
PUBLIC _approx_partial_derivative
	PUSH BP			
	MOV BP,SP						;set bp to use as pointer on stack
	PUSH SI							;save si value
	MOV SI,[BP+8]					;set si to point on x array
	MOV AX,8
	MUL WORD PTR [BP+6]				;calc the index of Xi
	MOV BX,AX						;get the index of Xi
	FLD QWORD PTR [SI+BX]			;ST[0]=Xi
	FILD QWORD PTR num 				;ST[0]=num ST[1]=Xi
	FDIV							;ST[0]=Xi/num
	FABS							;ST[0]=|Xi/num|
	FSTP QWORD PTR h				;get the start value of h
	PUSH h							;push variables for single_partial_derivative func
	PUSH QWORD PTR [BP+8]
	PUSH WORD PTR [BP+6]
	PUSH WORD PTR [BP+4]
	CALL _single_partial_derivative	;call to func
	ADD SP,20						;empty the stack
	FSTP QWORD PTR fd2				;initiate fd2
	loop1:
		FLD QWORD PTR fd2			;ST[0]=fd2
		FSTP QWORD PTR fd1			;fd1=fd2
		FLD QWORD PTR h				;ST[0]=h
		FILD QWORD PTR TWO			;ST[0]=TWO ST[1]=h
		FDIV						;ST[0]=h/TWO
		FSTP QWORD PTR h			;get the current h
		PUSH h						;push variables for single_partial_derivative func
		PUSH QWORD PTR [BP+8]
		PUSH WORD PTR [BP+6]
		PUSH WORD PTR [BP+4]
		CALL _single_partial_derivative;call to func
		ADD SP,20					;empty the stack
		FSTP QWORD PTR fd2			;fd2=return from single_partial_derivative
		FLD QWORD PTR fd1			;ST[0]=fd1
		FLD QWORD PTR num			;ST[1]=num ST[0]=fd1
		FDIV						;ST[0]=fd1/num
		FABS						;ST[0]=|fd1/num|
		FSTP QWORD PTR  RES 		;RES=|fd1/num|
		FLD QWORD PTR fd1			;ST[0]=fd1
		FLD QWORD PTR fd2			;ST[1]=fd2 ST[0]=fd1
		FSUB						;ST[0]=fd2-fd1
		FABS						;ST[0]=|fd2-fd1|
		FLD QWORD PTR RES			;ST[0]=|(fd1/num)| ST[1]=|(fd1-fd2)| 
		FCOMP 						;set flags as for ST[0]-ST[1]
		FSTSW AX					;save the math processor flags in ax
		SAHF 						;move the flags to cpu flags
		JBE loop1					;if fd1-fd2>=fd1/num jump ,else done
	FSTP QWORD PTR RES				;empty the math stack
	FLD QWORD PTR fd2				;st[0]= fd2
	POP SI							;restore registers value
	POP BP
RET
_approx_partial_derivative ENDP
END