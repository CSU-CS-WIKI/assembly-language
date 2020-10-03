;数字字符不能超过4位
;只能计算去掉小数点后0-255的值
.MODEL SMALL

.DATA
NUMIN BYTE 6,0,6 DUP(?);输入的数字
NUM WORD 0;转换后的数字
MULTIPLICAND BYTE ?;被乘数的尾数
MULTIPLIER BYTE ?;乘数的尾数
SIGN BYTE 0;符号位，初始为正
EXPONENT WORD 0;阶码
RESULT BYTE 8 DUP('0');输出的结果
ERROR BYTE 'Input Error','$'
GETPOINT WORD ?;用于判断是否接收过小数点
PUT0 BYTE 0;用于判断是否可以输出0

.CODE
MAIN PROC FAR
	MOV AX,@DATA
	MOV DS,AX
	
	;读取第一行输入
	LEA BX,MULTIPLICAND
	CALL INPUTP
	
	;输出回车
	MOV AH,2H
	MOV DL,0DH
	INT 21H
	MOV DL,0AH
	INT 21H
	
	;读取第二行输入
	LEA BX,MULTIPLIER
	CALL INPUTP
	
	;模拟乘法器运算，低8位放乘数
	;每次循环右移一位，若读取到1就将高8位和被乘数相加一次
	MOV CX,8
	MOV DL,MULTIPLIER
	MOV DH,0
	CLC
L1:
	RCR DX,1;带进位右移
	JNC LE1
	CLC
	ADD DH,MULTIPLICAND;在相加的时候可能进位
LE1:
	LOOP L1
	RCR DX,1;最后再右移一位排除第一次右移产生的0
	MOV NUM,DX
	
	;输出回车
	MOV AH,2H
	MOV DL,0DH
	INT 21H
	MOV DL,0AH
	INT 21H
	
	;输出结果
	CALL OUTPUT
	
	;结束程序
FIN:
	MOV AH,2H
	MOV DL,0DH
	INT 21H
	MOV DL,0AH
	INT 21H
	MOV AH,4CH
	INT 21H
MAIN ENDP

;需要输出的结果存NUM,符号存SIGN,阶码存EXPONENT
OUTPUT PROC NEAR
	;判断是否需要输出负号
	CMP SIGN,0
	JE CTN0
	MOV DL,'-'
	MOV AH,2H
	INT 21H
	
	;根据结果计算要输出的字符逆序循环存RESULT中
CTN0:
	MOV SI,0
	MOV BX,10
	MOV CX,8;输出最多8位
	MOV AX,NUM
CTN1:
	;判断是否应该输出小数点
	CMP SI,EXPONENT
	JNE CTN2
	MOV RESULT[SI],'.'
	JMP CTN1E
CTN2:
	;存储数字
	MOV DX,0
	DIV BX
	ADD RESULT[SI],DL
CTN1E:
	INC SI	
	LOOP CTN1
	
	;根据RESULT中的值进行逆序循环输出
	MOV CX,8
PUTN:
	MOV SI,CX
	DEC SI
	
	;如果是0且没开始输出，就跳过这个0
	CMP RESULT[SI],'0'
	JNE CMP2
	CMP PUT0,0
	JE PUTNE
CMP2:
	CMP RESULT[SI],'.'
	JNE PUTNI
	CMP PUT0,0
	JNE PUTNI
	;如果输出.时还没开始输出，就先输出0
	MOV DL,'0'
	MOV AH,2H
	INT 21H
	
	;普通输出
PUTNI:
	MOV PUT0,1
	MOV DL,RESULT[SI]
	MOV AH,2H
	INT 21H
PUTNE:
	LOOP PUTN
	
	RET
OUTPUT ENDP

;BX存要导入整数的内存地址
INPUTP PROC NEAR
	;输入
	MOV AH,0AH
	LEA DX,NUMIN
	INT 21H
	
	;初始化
	MOV CX,0
	MOV CL,NUMIN[1]
	MOV SI,2
	MOV GETPOINT,0
	MOV NUM,0
	
	;如果第一个字符为负号，就异或
	CMP NUMIN[2],'-'
	JNE NXTC1
	XOR SIGN,0FFH
	INC SI
	DEC CX
NXTC1:
	CMP NUMIN[2],'+'
	JNE NXTC2
	INC SI
	DEC CX
	
	;开始循环读取数字或小数点
NXTC2:
	CMP NUMIN[SI],'.'
	JNE NXTC3
	CMP GETPOINT,0
	JNE WRONG
	MOV GETPOINT,1
	MOV AX,0
	MOV AL,NUMIN[1]
	SUB AX,SI
	INC AX
	ADD EXPONENT,AX;加阶码
	JMP LE1
	
NXTC3:	
	CMP NUMIN[SI],'0'
	JB WRONG
	CMP NUMIN[SI],'9'
	JA WRONG
	CMP SI,2
	JNE CTN
	CMP NUMIN[1],4
	JA WRONG
CTN:
	PUSH CX;即将进入内层循环
	MOV CX,0
	MOV CL,NUMIN[1]
	SUB CX,SI
	INC CX
	
	MOV AX,0
	MOV AL,NUMIN[SI]
	SUB AX,'0'
	CMP GETPOINT,0
	JE MULL
	INC CX
	
	;内层循环
MULL:
	CMP CX,0
	JE BREAK
	
	MOV DX,10
	MUL DX
	LOOP MULL

BREAK:
	POP CX
	
	ADD NUM,AX
	
LE1:
	INC SI
	LOOP NXTC2
	
	;如果输入中没有小数点就可以直接比较，否则要除以10，因为在存的时候有小数点就多乘了10
	CMP GETPOINT,0
	JE CMP255
	MOV AX,NUM
	MOV DX,0
	PUSH BX;BX之前存了地址
	MOV BX,10
	DIV BX
	POP BX
	MOV NUM,AX
	ADD NUM,DX
	
CMP255:
	CMP NUM,255
	JA WRONG;如果数字大于255，就结束程序
	MOV AX,NUM
	MOV [BX],AL
	RET
	
WRONG:
	CALL ERRORP
	
INPUTP ENDP

;打印错误信息
ERRORP PROC NEAR
	LEA DX,ERROR
	MOV AH,9H
	INT 21H
	MOV AH,4CH
	INT 21H
ERRORP ENDP
END

