;blink_led.asm

list        p=16f877a   ; list directive to define processor
#include    <p16f877a.inc>  ; processor specific variable definitions

__config _HS_OSC & _WDT_OFF & _LVP_OFF & _PWRTE_ON 

;CP_ALL                      EQU     H'1FFF'
;_CP_OFF                      EQU     H'3FFF'
;_DEBUG_OFF                   EQU     H'3FFF'
;_DEBUG_ON                    EQU     H'37FF'
;_WRT_OFF                     EQU     H'3FFF'    ; No prog memmory write protection
;_WRT_256                     EQU     H'3DFF'    ; First 256 prog memmory write protected
;_WRT_1FOURTH                 EQU     H'3BFF'    ; First quarter prog memmory write protected
;_WRT_HALF                    EQU     H'39FF'    ; First half memmory write protected
;_CPD_OFF                     EQU     H'3FFF'
;_CPD_ON                      EQU     H'3EFF'
;_LVP_ON                      EQU     H'3FFF'
;_LVP_OFF                     EQU     H'3F7F'
;_BODEN_ON                    EQU     H'3FFF'
;_BODEN_OFF                   EQU     H'3FBF'
;_PWRTE_OFF                   EQU     H'3FFF'
;_PWRTE_ON                    EQU     H'3FF7'
;_WDT_ON                      EQU     H'3FFF'
;_WDT_OFF                     EQU     H'3FFB'
;_RC_OSC                      EQU     H'3FFF'
;_HS_OSC                      EQU     H'3FFE'
;_XT_OSC                      EQU     H'3FFD'
;_LP_OSC                      EQU     H'3FFC'


STATUS EQU 0x03
PORTB EQU 0x06
TRISB EQU 0x86
PORTD EQU 0x08
TRISD EQU 0x88

CBLOCK 0x20
		Count120us ;Delay count (number of instr cycles for Delay)
		Count100us
		Count1ms
		Count10ms
		Count1s
        CountHalfs
		Count10s
		Count1m
ENDC


org 0x0000 			;line 1
		goto START 	;line 2 ($0000)
org 0x05
START
		banksel TRISD 	    ;select bank for TRIS register
		movlw   0x00	    ;set port D and port B as output port by moving 0x00 to TRISD and TRISB
		movwf   TRISD 	    ; this part is not important as now i start only to blink LED at port B
		movwf   TRISB 	    ; now PORTB is set as output
		banksel PORTB 	    ;select bank for PORTB and PORTD
		clrf    PORTB 	    ; clear PORTB  (output is low now for RB0:RB7)
		clrf    PORTD 	    ; clear PORTD	(output is low now for RD0:RD7), this part is not important as now i start only to blink LED at port B
		call    Delay100ms 	;call subroutine for 100mS delay
		
repeat	
		movlw 0xFF	        ;Move '0b11111111' to PORTB register
		movwf PORTB 	    ;All LED at PORTB should be light up now
		Call DelayHalfs 	    ; call subroutine for 1s delay
        Call Delay1ms ; tuning
		movlw 0x00 	        ; Move '0b00000000' to PORTB register
		movwf PORTB 	    ; All LED at PORTB should be dimmed now
		Call DelayHalfs 	    ; call subroutine for 1s delay
        Call Delay1ms ; tuning
		goto repeat 	    ; goback to 'repeat' infinite loop

;==========================================================
;DELAY SUBROUTINES (delay routines is written based on 20MHz Crystal)
Delay120us
		banksel Count120us
		movlw H'C5' ;D'197'
		movwf Count120us
R120us
		decfsz Count120us
		goto R120us
		return
;
Delay100us
		banksel Count100us
		movlw H'A3' ; subtracted one to ensure accuracy
		movwf Count100us
R100us
		decfsz Count100us
		goto R100us
		return
;
;1ms Delay
Delay1ms
		banksel Count1ms
		movlw 0x0A ;10
		movwf Count1ms
R1ms 
		call Delay100us
		decfsz Count1ms
		goto R1ms
		return
;
;10ms Delay
; call 100 times of 100 us Delay (with some time discrepancy)
Delay10ms
		banksel Count10ms
		movlw H'64' ;100
		movwf Count10ms
R10ms 
		call Delay100us
		decfsz Count10ms
		goto R10ms
		return
;;
;1 sec Delay
;call 100 times of 10ms Delay
Delay1s
		banksel Count1s
		movlw H'64'
		movwf Count1s
R1s 
		call Delay10ms
		decfsz Count1s
		goto R1s
		return
;;
;.5 sec Delay
;call 50 times the 10ms Delay
DelayHalfs
		banksel CountHalfs
		movlw H'32'
		movwf CountHalfs
RHalfs 
		call Delay10ms
		decfsz CountHalfs
		goto RHalfs
		return
;;
;10 s Delay
;call 10 tiems of 1 s Delay
Delay10s
		banksel Count10s
		movlw H'0A' ;10
		movwf Count10s
R10s 
		call Delay1s
		decfsz Count10s
		goto R10s
		return
;
;1 min Delay
;call 60 times of 1 sec Delay
Delay1m
		banksel Count1m
		movlw H'3C' ;60
		movwf Count1m
R1m 
		call Delay1s
		decfsz Count1m
		goto R1m
		return

;;
;100 msec Delay
;call 10 times of 10ms Delay
Delay100ms
		banksel Count1s
		movlw H'0A' ;10
		movwf Count1s
R100ms 
		call Delay10ms
		decfsz Count1s
		goto R100ms
		return
;;
;======================================================
END

;Increase delay at instw and dataw to 100ms and start up to 100ms (2014-1-7) 