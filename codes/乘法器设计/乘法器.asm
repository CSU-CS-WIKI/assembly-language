;�����ַ����ܳ���4λ
;ֻ�ܼ���ȥ��С�����0-255��ֵ
.MODEL SMALL

.DATA
NUMIN BYTE 6,0,6 DUP(?);���������
NUM WORD 0;ת���������
MULTIPLICAND BYTE ?;��������β��
MULTIPLIER BYTE ?;������β��
SIGN BYTE 0;����λ����ʼΪ��
EXPONENT WORD 0;����
RESULT BYTE 8 DUP('0');����Ľ��
ERROR BYTE 'Input Error','$'
GETPOINT WORD ?;�����ж��Ƿ���չ�С����
PUT0 BYTE 0;�����ж��Ƿ�������0

.CODE
MAIN PROC FAR
	MOV AX,@DATA
	MOV DS,AX
	
	;��ȡ��һ������
	LEA BX,MULTIPLICAND
	CALL INPUTP
	
	;����س�
	MOV AH,2H
	MOV DL,0DH
	INT 21H
	MOV DL,0AH
	INT 21H
	
	;��ȡ�ڶ�������
	LEA BX,MULTIPLIER
	CALL INPUTP
	
	;ģ��˷������㣬��8λ�ų���
	;ÿ��ѭ������һλ������ȡ��1�ͽ���8λ�ͱ��������һ��
	MOV CX,8
	MOV DL,MULTIPLIER
	MOV DH,0
	CLC
L1:
	RCR DX,1;����λ����
	JNC LE1
	CLC
	ADD DH,MULTIPLICAND;����ӵ�ʱ����ܽ�λ
LE1:
	LOOP L1
	RCR DX,1;���������һλ�ų���һ�����Ʋ�����0
	MOV NUM,DX
	
	;����س�
	MOV AH,2H
	MOV DL,0DH
	INT 21H
	MOV DL,0AH
	INT 21H
	
	;������
	CALL OUTPUT
	
	;��������
FIN:
	MOV AH,2H
	MOV DL,0DH
	INT 21H
	MOV DL,0AH
	INT 21H
	MOV AH,4CH
	INT 21H
MAIN ENDP

;��Ҫ����Ľ����NUM,���Ŵ�SIGN,�����EXPONENT
OUTPUT PROC NEAR
	;�ж��Ƿ���Ҫ�������
	CMP SIGN,0
	JE CTN0
	MOV DL,'-'
	MOV AH,2H
	INT 21H
	
	;���ݽ������Ҫ������ַ�����ѭ����RESULT��
CTN0:
	MOV SI,0
	MOV BX,10
	MOV CX,8;������8λ
	MOV AX,NUM
CTN1:
	;�ж��Ƿ�Ӧ�����С����
	CMP SI,EXPONENT
	JNE CTN2
	MOV RESULT[SI],'.'
	JMP CTN1E
CTN2:
	;�洢����
	MOV DX,0
	DIV BX
	ADD RESULT[SI],DL
CTN1E:
	INC SI	
	LOOP CTN1
	
	;����RESULT�е�ֵ��������ѭ�����
	MOV CX,8
PUTN:
	MOV SI,CX
	DEC SI
	
	;�����0��û��ʼ��������������0
	CMP RESULT[SI],'0'
	JNE CMP2
	CMP PUT0,0
	JE PUTNE
CMP2:
	CMP RESULT[SI],'.'
	JNE PUTNI
	CMP PUT0,0
	JNE PUTNI
	;������.ʱ��û��ʼ������������0
	MOV DL,'0'
	MOV AH,2H
	INT 21H
	
	;��ͨ���
PUTNI:
	MOV PUT0,1
	MOV DL,RESULT[SI]
	MOV AH,2H
	INT 21H
PUTNE:
	LOOP PUTN
	
	RET
OUTPUT ENDP

;BX��Ҫ�����������ڴ��ַ
INPUTP PROC NEAR
	;����
	MOV AH,0AH
	LEA DX,NUMIN
	INT 21H
	
	;��ʼ��
	MOV CX,0
	MOV CL,NUMIN[1]
	MOV SI,2
	MOV GETPOINT,0
	MOV NUM,0
	
	;�����һ���ַ�Ϊ���ţ������
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
	
	;��ʼѭ����ȡ���ֻ�С����
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
	ADD EXPONENT,AX;�ӽ���
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
	PUSH CX;���������ڲ�ѭ��
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
	
	;�ڲ�ѭ��
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
	
	;���������û��С����Ϳ���ֱ�ӱȽϣ�����Ҫ����10����Ϊ�ڴ��ʱ����С����Ͷ����10
	CMP GETPOINT,0
	JE CMP255
	MOV AX,NUM
	MOV DX,0
	PUSH BX;BX֮ǰ���˵�ַ
	MOV BX,10
	DIV BX
	POP BX
	MOV NUM,AX
	ADD NUM,DX
	
CMP255:
	CMP NUM,255
	JA WRONG;������ִ���255���ͽ�������
	MOV AX,NUM
	MOV [BX],AL
	RET
	
WRONG:
	CALL ERRORP
	
INPUTP ENDP

;��ӡ������Ϣ
ERRORP PROC NEAR
	LEA DX,ERROR
	MOV AH,9H
	INT 21H
	MOV AH,4CH
	INT 21H
ERRORP ENDP
END

