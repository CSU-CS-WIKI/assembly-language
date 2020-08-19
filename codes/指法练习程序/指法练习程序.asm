init_game macro op1,op2,op3,op4,op5,op6		;ѭ��������ڳ�ʼ������
	;DH�к�  DL�к� CX=0
	mov cx,0
	mov dh,op1								;��ʼ��
	mov dl,op2								;��ʼ��
op6:
	mov ah,02h
	mov bh,00h
	int 10h

	push cx
	mov ah,09h
	mov al,op3								;Ҫ��ʾ���ַ� al=�ַ���ascii��
	mov cx,01h								;д���ַ��ظ�����
	mov bh,00h								;ҳ��
	mov bl,0afh								;������ɫ
	int 10h
	pop cx

	inc cx
	inc op4									;ָ��ѭ����������л�����
	cmp cx,op5								;ѭ������
	jne op6
endm

clean macro op1,op2,op3,op4					;�����������ֱ�����ֹ���к��к�
	;CL���Ͻ��к� CH���Ͻ��к� DL���Ͻ��к� DH���Ͻ��к�
	mov ah,06h
	mov al,00h
	mov bh,09h								;�ı������Ե�ɫ�ʣ��ֵ�ɫ�� bh��ʾ�հ��е�����
	mov ch,op1
	mov cl,op2
	mov dh,op3
	mov dl,op4
	int 10h

	mov ah,02h								;���ù��λ��
	mov bh,00h
	mov dh,00h
	mov dl,00h
	int 10h
endm

menu macro op1,op2,op3						;�˵���ʾ�궨�壬������Ļ�Ϸ����ֵ����
	;DH�к�  DL�к�
	mov ah,02h
	mov bh,00h
	mov dh,op1
	mov dl,op2
	int 10h
	
	mov ah,09h
	lea dx,op3
	int 21h
endm

DATAS SEGMENT
	;�˴��������ݶδ���
	fgf db '*******************************************$'
    m1 db 'WELCOME TO PLAY$'
    m2 db 'date:2019/3/22$'
    m3 db 'please press 1 or 2 to continue$'
    menu1 db '1.Start game$'
    menu2 db '2.Exit$'
    menu3 db 'Select number of menu:$'
    menu4 db 'Please input right number$'

    level1 db 'Please choose a level of the new game:$'
    easy   db '1.EASY$'
    hard   db '2.HARD$'
    menu5 db 'Select number of level:$'

    meg db 'Press Enter key to continue *_*$'
    meg1 db 'When a letter is dropping,please hit it!$'
    meg2 db 'Press space key to pause!$'
    meg3 db 'Press ESC key to return to main interface!$'
    meg4 db 'When the game was paused,press ESC to quit!$'
    
    mesmissing db 'MISSING:$'				
    messcore db 'SCORE:$' 					;����
    meg7 db 'hit the letter num:$'
    meg8 db 'the missing letter num:$'
    meg9 db 'the shooting is:$'

    letter db 0								;�����������ĸ
    speed dw 0                              ;��ĸ������ٶ�
    sped1 dw 50000
    position db 0                           ;��ĸ�����λ�ã����кţ�
    n db 26 								;�����������ĸҪ����ת��
    score db 0								;����
    missing db 0							;�������ĸ��
    scoreshi db 0							;������ʮλ
	scorege db 0							;�����ĸ�λ
    hitshi db 0								;����������ʮλ��
    hitge db 0								;�����ʵĸ�λ��
    missshi db 0							;�����ʮλ��
    missge db 0								;����ĸ�λ��
    
    hang db 0
    lie db 0								;��¼����ʱ��ĸ�����к�
    
    string db '100%$'						;��ʼ���Ļ����ʣ�֮��Ҫ���ݷ����ʹ��������ת������
    
    row db 0
DATAS ENDS

STACKS SEGMENT
    ;�˴������ջ�δ���
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
;��ʼ����ҳ
START:
	MOV AX,DATAS
    MOV DS,AX
    ;�˴��������δ���

index:
	;�������ʼ�� �ù�����ͣ����ع��
	mov ah,01h
	mov cx,00h
	or ch,00010111b
	int 10h

	clean 0,0,24,80
	;����Ǵ�ӡ�����ַ�
	init_game 0,0,03h,dl,80,s
	init_game 24,0,03h,dl,80,s1
	;init_game 0,0,03h,dh,25,s2
	;init_game 0,80,03h,dh,25,s3
	;����ַ�
	menu 3,15,fgf
	menu 5,25,m1
	menu 7,25,m2
	menu 9,25,m3
	menu 11,25,menu1
	menu 13,25,menu2
	menu 15,15,fgf
	menu 17,25,menu3

;����ѡ���ܣ�������Ϸ�����˳���Ϸ��
fun_input:
	;����
	mov ah,2
	mov bh,0
	mov dh,15
	mov dl,47
	int 10h
	
	mov ah,1
	int 21h
	
	cmp al,49                         ;��������1���������Ϸ
	je gametip					      ;��Ϸ��ʼ	
   	cmp al,50                         ;��������2����esc���˳�����
   	je exithigh
   	cmp al,1bh
   	je exithigh
   	jmp errortip1


;��Ϸ��ʼ��������ʾ
gametip:			
	clean 0,0,24,80						;����
	;clean 1,0,23,80					;�������������������İ�������					
	menu 5,15,fgf					;��ʼ����ʾ��
	menu 7,15,meg
	menu 9,15,meg1
	menu 11,15,meg2
	menu 13,15,meg3
	menu 15,15,meg4
	menu 17,15,fgf
	
	mov ah,07h
	int 21h
	
	cmp al,1bh                        ;�������������esc����
	je index	                      ;��esc���½��������棨���˳���ǰ��Ϸ��

;����ѡ���ٶȽ���
choose_speed:
	;clean 1,0,23,80
	clean 0,0,24,80
	menu 7,15,fgf
	menu 9,15,level1
	menu 11,15,easy
	menu 11,40,hard
	menu 13,15,fgf
	menu 15,25,menu5

;�ٶ�ѡ��
speed_input:
	mov ah,2
	mov dh,15
	mov dl,49
	int 10h
	mov ah,1
	int 21h
	
	cmp al,49                         ;��������1����ѡ���ٶȼ�
	je speedeasy					 
   	cmp al,50                         ;��������2����ѡ���ٶ�����
   	je speedhard
   	cmp al,1bh
   	je index
   	jmp errortip2

speedeasy:
	mov speed,10
	jmp play
speedhard:
	mov speed,2  

;��ʼ��Ϸ	
play:
	;clean 1,0,22,80
	clean 0,0,24,80

	call init_score_missing	         ;����Ϸ��������ʾ��ʼ����score�ʹ������ĸ��missing

sub_position:
	sub position,78
	cmp position,0
	jne sub_position_big
	inc position

sub_position_big:
	jmp output_letter

new_position:
	mov ah,2ch                        ;ȡϵͳʱ������������ȷ��������ĸ���к�
	int 21h
	mov al,dl
	mov position,al                   ;positionΪ��ĸ���к�
	cmp position,0
	jne position_big
	inc position

position_big:
	cmp position,78
	ja sub_position

;�ڶ�Ӧ��������µ���ĸ
output_letter:
	mov dl,position
	mov ah,02h
	mov al,letter
	mov dh,1
	int 10h

;�ȴ������Լ���������ʱ��	
temp:
	mov cx,0

nextrow:
	push cx
	mov cx,0

yanchi:
	push cx
	mov cx,0

yanchi1:
	add cx,1
	cmp cx,sped1
	jne yanchi1
	push dx
	mov ah,06h							;ֱ�ӿ���̨�����룩
	mov dl,0ffh
	int 21h
	pop dx
	cmp al,0
	int 10h	
	jz pass

;��Ϸ�����еĲ���	
action:
	cmp al,32
	je pause                              ;����ո���ͣ
	cmp al,1bh
	je exitlow                            ;����esc�˳�
	jmp drop

pause:
	push dx
	mov ah,06h
	mov dl,0ffh
	int 21h
	pop dx
	
	cmp al,20h
	jne pause
	jmp pass

;��Ϸ�е��˳���������ʾ�����	
exitlow:
	;clean 1,0,23,80
	clean 0,0,24,80
	call result

drop:
	cmp al,letter
	je get_score                       		;��������������ĸһ�������������ʧ���ҼƷ�
	jmp pass                              	;��������������ĸ��һ�������������

get_score:
	;ȡ����,���ں������֮����ʧ
	mov bh,0
	mov ah,3
	int 10h	
	
	mov hang,dh
	mov lie,dl
	int 10h
	
	call letter_bright

fasheng:	
	call sound
	
letter_disappear:
	call disappear

pass:
	pop cx
	inc cx
	cmp cx,speed                          ;speedΪ����
	
	je print
	jmp yanchi

print:
	;���������ʱû�������ַ�ʱ���ÿո񸲸�ԭ���ַ���ͬʱ�ַ�����
	mov ah,0ah
	mov bh,0
	mov al,32
	mov cx,1
	int 10h
	
	inc dh                               ;������λ������һ�У��кż�һ������һ��
	mov ah,02h
	mov bh,0
	int 10h	
	
	mov ah,0ah
	mov al,letter
	mov bh,0
	mov cx,1
	int 10h
	
	pop cx
	inc cx
	cmp cx,21
	
	je bottom
	jmp nextrow


bottom:
	;����ĸ��������»�û����������Ҫ���²���һ����ĸ������ԭ��λ�ò���ʹ�������ĸ��+1
	push ax
	mov al,missing
	inc al
	mov missing,al
	pop ax
	
	mov bh,0                                      ;ȡ���λ��
	mov ah,3
	int 10h
	
	mov lie,dl
	int 10h 
	
;����������ĸ����������˺�����ֱ������new_letter������ʵ���ֲ�����ĸ�Ĺ���	
print_missing:
	mov ah,02h
	mov dl,32
	int 21h
	
	;ʵʱ����������ĸ��	
	push ax
	push bx
	mov al,missing
	mov ah,0
	mov bl,10
	div bl
	mov missshi,al
	mov missge,ah
	pop bx
	pop ax
	
	mov ah,2
	mov bh,0
	mov dh,23
	mov dl,60
	int 10h
	
	mov al,missshi
	mov dl,al
	add dl,30h
	mov ah,2
	int 21h
	
	mov dl,missge
	add dl,30h
	mov ah,2
	int 21h

;����һ������ĸ
new_letter:
	mov ah,2ch                                    	;ȡϵͳʱ��
	int 21h                        
	mov ah,0                                       
	mov al,dl										;�����̷���al����������al
	div n
	add ah,61h
	mov letter,ah                                   ;�����µ���ĸ
	int 10h
	
	mov ah,02h     									;���ù��λ��
	mov bh,00h
	mov dh,hang    
	mov dl,lie
	int 10h
	
	mov ah,09h										;�ÿո����ԭ����ĸλ�õ�����
	mov al," "
	mov bh,0
	mov cx,1
	mov bl,00h
	int 10h
	
	jmp new_position

;��ѡ��˵�����������ʱ�������������ʾ
errortip1:											
	push ax
	mov ah,1
	int 21h
	menu 17,25,menu4
	mov ah,2
	mov bh,0
	mov bh,0
	mov dh,15
	mov dl,47
	int 10h
	
	mov ah,0ah
	mov al,32
	mov bh,00h
	mov cx,01h
	int 10h
	jmp fun_input

;��ѡ���ٶ�����������ʱ�������������ʾ
errortip2:							
	push ax
	mov ah,1
	int 21h
	menu 17,25,menu4
	mov ah,2
	mov bh,0
	mov bh,0
	mov dh,15
	mov dl,47
	int 10h
	
	;�ƹ��
	mov ah,2
	mov bh,0
	mov dh,15
	mov dl,49
	int 10h
	
	mov ah,0ah
	mov al,32
	mov bh,00h
	mov cx,01h
	int 10h
	jmp speed_input

exithigh:							;�˳�����
	mov ah,6
	mov bh,7						;����
	mov al,0
	mov ch,0
	mov cl,0
	mov dh,24
	mov dl,80
	int 10h
	
	mov ah,2
	mov bh,0
	mov dh,0
	mov dl,0
	int 10h                          
	
	mov ah,4ch
	int 21h

;��ʾ��ʼ�����ʹ���ĸ���
init_score_missing proc near

	menu 23,10,messcore
	menu 23,50,mesmissing
	init_game 22,0,' ',dl,80,sk5
	
	push dx
		
	mov ah,2
	mov dh,23
	mov dl,18
	int 10h
	
	mov ah,2
	mov dl,score
	add dl,30h
	int 21h
	
	mov ah,2
	mov dh,23
	mov dl,60
	int 10h
	
	mov ah,02h
	mov dl,missing
	add dl,30h
	int 21h
	
	jmp new_letter
init_score_missing endp

;disappear�������壨ʹ�����е���ĸ��ʧ��ͬʱˢ�µ÷֣�
disappear proc near	
	inc score	
	;ʵʱ�������	
	push ax
	push bx
	mov al,score
	mov ah,0
	mov bl,10
	div bl
	mov scoreshi,al
	mov scorege,ah
	pop bx
	pop ax	
	
	mov ah,2
	mov bh,0			;������ʧ���ַ�
	mov dl,18
	mov dh,23
	int 10h
	
	mov dl,scoreshi
	add dl,30h
	mov ah,2
	int 21h
	
	mov dl,scorege
	add dl,30h
	mov ah,2
	int 21h
	
	jmp new_letter
disappear endp

;letter_bright������ʼ
;��ĸ����
letter_bright proc near	
	mov ah,09h
	mov al,letter                            ;Ҫ��ʾ�ַ�
	mov cx,01h
	mov bh,00h
	mov bl,0a0h                            ;������ɫ
	int 10h
	
	jmp fasheng
letter_bright endp

;sound��������
sound proc
	mov al,0b6h                    ;�������д������
	out 43h,al                     ;��ʽ3��˫�ֽ�д�Ͷ����Ƽ�����ʽд�����ƿ�
	mov dx,12h                     ;��������������
	mov ax,348ch
	mov bx,900
	div bx
	out 42h,al                     ;����lsb
	mov al,ah
	out 42h,al                     ;����msb
	;��61�˿ڲ������壬��������
	;���˿�ԭֵ
	in al,61h                      
	or al,3
	out 61h,al                     ;��ͨ������
	call delay0
	mov al,ah
	out 61h,al
	jmp letter_disappear
sound endp

;����ʱ�亯��
delay0 proc
	push cx
	push ax	
	mov cx,0ffffh
delay1:
	mov ax,0010h
delay2:
	dec ax
	jnz delay2
	loop delay1
	pop ax
	pop cx
	ret
delay0 endp

;result��������Ϸ��������ʾ�÷ֺ�������
result proc near
	menu 5,15,fgf
	menu 7,25,meg7
	menu 9,25,meg8
	menu 11,25,meg9
	menu 13,15,fgf
	
	push ax
	push bx
	mov al,score
	mov ah,0
	mov bl,10
	div bl
	mov scoreshi,al
	mov scorege,ah
	pop bx
	pop ax
	
	mov ah,2
	mov dl,45
	mov dh,7
	int 10h
	
	mov al,scoreshi
	mov dl,al
	add dl,30h
	mov ah,2
	int 21h
	
	mov dl,scorege
	add dl,30h
	mov ah,2
	int 21h
	
	pop dx
	pop ax
		
	push ax
	push bx
	mov al,missing
	mov ah,0
	mov bl,10
	div bl
	mov missshi,al
	mov missge,ah
	pop bx
	pop ax
	
	mov ah,2
	mov dl,51
	mov dh,9
	int 10h
	
	mov al,missshi
	mov dl,al
	add dl,30h
	mov ah,2
	int 21h
	
	mov dl,missge
	add dl,30h
	mov ah,2
	int 21h
	
	pop dx
	pop ax
	
	push ax
	push bx
	push cx
	push dx
	
	mov ah,2
	mov dl,44
	mov dh,11
	int 10h
	;���������
	mov al,score
	mov dl,missing
	add dl,al
	cmp al,dl
	jne caculate
	
	push dx
	mov ah,09h
	lea dx,string
	int 21h
	pop dx
	
	jmp end_game

caculate:
	mov bl,10
	mul bl
	div dl
	mov hitshi,al
	
	mov al,ah
	mul bl
	div dl
	mov hitge,al
	
hitlv:
	push dx
	mov dl,hitshi
	add dl,30h
	mov ah,2
	int 21h
	
	mov dl,hitge
	add dl,30h
	mov ah,2
	int 21h
	
	mov ah,2
	mov dl,25h                         ;���%
	int 21h
	pop dx

end_game:
	mov ah,7
	int 21h
	cmp al,1bh
	jne end_game
	
	jmp start
result endp
	
codes ends
	end start




