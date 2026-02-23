; SPDX-License-Identifier: Apache-2.0
; Copyright (c) 2025-2026 Claudio Lorenzo La Rosa
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;     http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

; GRam_OS version 0.07


.ORG 0

.INCLUDE list.i
.INCLUDE serial.i
.INCLUDE SDCard.i

.DATA
	
	str_ser1_init		DC4.T "Serial Port 1 & 2 initialized at 9600 bps. OS output now is on Serial 2.",0
	str_copyr			DC4.T "(C) Copyright 2024-2026 Claudio La Rosa under Apache 2.0 License",0
	str_cpu				DC4.T "CPU: ",0
	str_unk				DC4.T "Unknown!",0
	str_5500FP			DC4.T "5500FP",9,0
	str_5_1				DC4.T "5.1",0
	str_ES3_1			DC4.T " ES 3.1",0
	str_welcome			DC4.T "WELCOME! ",0
	str_welcome_2		DC4.T "GRam_OS for 5500 CPU",0
	str_version_head	DC4.T "Version: ",0
	str_version			DC4.T "0.07",10,13,0
	str_stack			DC4.T "Stack base @ AZ8 (8000)",10,13,0
	str_memorycheck		DC4.T "Memory size check... ",0
	str_memorysize_1_5	DC4.T "Memory is 16 MWord (64 MTryte) on GargantuRAM 1.5 Motherboard ",0


	str_computer_type	DC4.T "Computer: ",0
	;Brand computer
	str_brand_MOS		DC4.T "MOS/Ternary Computer System (TCS) ",0
	;MOS/TCS Models
	str_model_gram		DC4.T "GargantuRAM ",0
	;Boards version
	str_one_point_three	DC4.T "1.3 ",0
	str_one_point_four	DC4.T "1.4 ",0
	str_one_point_fivePRE	DC4.T "1.5 PRE ",0


	;Shell strings
	str_prompt			DC4.T "1.[CMD]-> ",0
	str_cmd_unk			DC4.T "Command not recognized.",0

	shell_cmd_version	DC4.T "version",0
	shell_cmd_cls		DC4.T "cls",0
	shell_cmd_run		DC4.T "run",0
	shell_cmd_list		DC4.T "ls",0

	str_dir_sd			DC4.T "Content of disk SD0:",0

	str_file_not_found	DC4.T "File not found on SD Card.",0
	str_file_found			DC4.T "File found ad index: ",0

		
	;
	; ERRORS
	;
	str_div_by_zero		DC4.T "Division By Zero: FATAL error.",0
	str_reserved_int	DC4.T "RESERVED INSTRUCTION.",0
	str_unk_int			DC4.T "Unknown Instruction: FATAL error.",0
	str_generic_int		DC4.T "Generic Interrupt occurred. ",0 ;Interrupt number: ",0




.CODE

	; ----------------    Disable ALL Interrupts ---------------------------------------- 

	 DI
    ; ----------------------------------------------------------------------------------

	;-------- Stack initializing ----------
	 ANYI R60,R0,#8000	;R60 Stack address
	 STSP R60			;Kernel Stack 
	;--------------------------------------


	;---------------Serial 1 output (I am alive!) ----------------
	 ANYI R7,R0,#SERIAL_PORT_1
	 LEA R3,str_ser1_init
	 JSR println

	;--------------------------------------
	;Set Serial Port (R7)
	 ANYI R7,R0,#SERIAL_PORT_2
	;---------------------------------------


	;------------  Clear the screen  ------------------
	JSR ANSI_clear_screen

	;------------  Welcome and (c) messages -----------
	ANYI R27,R0,#33	;ANSI Yellow foreground
	ANYI R28,R0,#40	;ANSI Black background
	LEA R29,str_welcome
	JSR ANSI_write_color

	LEA R3,str_welcome_2
	JSR println

	LEA R3,str_version_head
	JSR print
	LEA R3,str_version
	JSR println

	LEA R3,str_copyr
	JSR println
	;--------------------------------------------------
		
	;---------------  CPU ID ----------------
	CID R15
	;-----------------------------------------
	

	ANYI R8,R0,#-40
	TXOR R8,R8,R15

	LEA R3,str_cpu	;address of string in R3
	JSR print

	ANYI R9,R0,#-40
	JEQ R8,R9,print_fivefive
	
	LEA R3,str_unk
	JSR println
	JMP exit_CPU

	print_fivefive:
	LEA R3,str_5500FP
	JSR print

	cpu_version:
	ASHI R15,R15,#4

	ANYI r8,r0,#-4
	TXOR r8,r8,R15

	ANYI r9,r0,#-3
	JEQ r8,r9,version_5_1
	JMP exit_CPU
	
	version_5_1:
	LEA R3,str_5_1
	JSR print
	LEA R3,str_ES3_1
	JSR println
	
	exit_CPU:

	JSR check_computer

	
	;View Stack info
	LEA r3,str_stack
	JSR println

	;Check memory size
	LEA R3,str_memorycheck
	JSR println
	LEA R3,str_memorysize_1_5
	JSR println



	;set the Interrupt Base Register
	LEA R3,interrupt_vector
	STITBR R3
	
	;------ ENABLE INTERRUPT -----------
	EI
	;-----------------------------------
	

	;jump to start shell
	JMP start_os

	;---------  INTERRUPT VECTORs  -----------------
	interrupt_vector:
;Interrupt 0 (GENERIC)
JMP int_generic_handler
;Interrupt 1 (GENERIC)
JMP int_generic_handler
;Interrupt 2 (GENERIC)
JMP int_generic_handler
	;Interrupt 3 (** RETURN TO OS **)
	JMP int_return_to_os
	;Interrupt 4 ** IO.library **
	JMP int_IO_library
;Interrupt 5 (GENERIC)
JMP int_generic_handler
;Interrupt 6 (GENERIC)
    JMP int_generic_handler
;Interrupt 7 (GENERIC)
    JMP int_generic_handler
;Interrupt 8 (GENERIC)
    JMP int_generic_handler
;Interrupt 9 (GENERIC)
    JMP int_generic_handler
;Interrupt 10 (GENERIC)
    JMP int_generic_handler
;Interrupt 11 (GENERIC)
    JMP int_generic_handler
;Interrupt 12 (GENERIC)
    JMP int_generic_handler
;Interrupt 13 (GENERIC)
    JMP int_generic_handler
;Interrupt 14 (GENERIC)
    JMP int_generic_handler
;Interrupt 15 (GENERIC)
    JMP int_generic_handler
;Interrupt 16 (GENERIC)
    JMP int_generic_handler
;Interrupt 17 (GENERIC)
    JMP int_generic_handler
;Interrupt 18 (GENERIC)
    JMP int_generic_handler
;Interrupt 19 (GENERIC)
    JMP int_generic_handler
;Interrupt 20 (GENERIC)
    JMP int_generic_handler
;Interrupt 21 (GENERIC)
    JMP int_generic_handler
;Interrupt 22 (GENERIC)
    JMP int_generic_handler
;Interrupt 23 (GENERIC)
    JMP int_generic_handler
;Interrupt 24 (GENERIC)
    JMP int_generic_handler
;Interrupt 25 (GENERIC)
    JMP int_generic_handler
;Interrupt 26 (GENERIC)
    JMP int_generic_handler
;Interrupt 27 (GENERIC)
    JMP int_generic_handler
;Interrupt 28 (GENERIC)
    JMP int_generic_handler
;Interrupt 29 (GENERIC)
    JMP int_generic_handler
;Interrupt 30 (GENERIC)
    JMP int_generic_handler
;Interrupt 31 (GENERIC)
    JMP int_generic_handler
;Interrupt 32 (GENERIC)
    JMP int_generic_handler
;Interrupt 33 (GENERIC)
    JMP int_generic_handler
;Interrupt 34 (GENERIC)
    JMP int_generic_handler
;Interrupt 35 (GENERIC)
    JMP int_generic_handler
;Interrupt 36 (GENERIC)
    JMP int_generic_handler
;Interrupt 37 (GENERIC)
    JMP int_generic_handler
;Interrupt 38 (GENERIC)
    JMP int_generic_handler
;Interrupt 39 (GENERIC)
    JMP int_generic_handler
;Interrupt 40 (GENERIC)
    JMP int_generic_handler
;Interrupt 41 ** SERIAL 1 RX **
JMP int_serial1_rx
;Interrupt 42 ** SERIAL 2 RX **
JMP int_serial2_rx
;Interrupt 43 *** RTC TICK ***
JMP int_RTC
;Interrupt 44 *** Timer 1 ***
JMP int_Timer_1
;Interrupt 45 *** Timer 2 ****
JMP int_Timer_2
;Interrupt 46 *** Timer 3 ***
JMP int_Timer_3
;Interrupt 47 *** Timer 4 ***
JMP int_Timer_4
;Interrupt 48 (GENERIC)
    JMP int_generic_handler
;Interrupt 49 (GENERIC)
    JMP int_generic_handler
;Interrupt 50 (GENERIC)
    JMP int_generic_handler
;Interrupt 51 (GENERIC)
    JMP int_generic_handler
;Interrupt 52 (GENERIC)
    JMP int_generic_handler
;Interrupt 53 (GENERIC)
    JMP int_generic_handler
;Interrupt 54 (GENERIC)
    JMP int_generic_handler
;Interrupt 55 (GENERIC)
    JMP int_generic_handler
;Interrupt 56 (GENERIC)
    JMP int_generic_handler
;Interrupt 57 (GENERIC)
    JMP int_generic_handler
;Interrupt 58 (GENERIC)
    JMP int_generic_handler
;Interrupt 59 (GENERIC)
    JMP int_generic_handler
;Interrupt 60 (GENERIC)
    JMP int_generic_handler
;Interrupt 61 (GENERIC)
    JMP int_generic_handler
;Interrupt 62 (GENERIC)
    JMP int_generic_handler
;Interrupt 63 (GENERIC)
    JMP int_generic_handler
;Interrupt 64 (GENERIC)
    JMP int_generic_handler
;Interrupt 65 (GENERIC)
    JMP int_generic_handler
;Interrupt 66 (GENERIC)
    JMP int_generic_handler
;Interrupt 67 (GENERIC)
    JMP int_generic_handler
;Interrupt 68 (GENERIC)
    JMP int_generic_handler
;Interrupt 69 (GENERIC)
    JMP int_generic_handler
;Interrupt 70 (GENERIC)
    JMP int_generic_handler
;Interrupt 71 (GENERIC)
    JMP int_generic_handler
;Interrupt 72 (GENERIC)
    JMP int_generic_handler
;Interrupt 73 (GENERIC)
    JMP int_generic_handler
;Interrupt 74 (GENERIC)
    JMP int_generic_handler
;Interrupt 75 (GENERIC)
    JMP int_generic_handler
;Interrupt 76 (GENERIC)
    JMP int_generic_handler
;Interrupt 77 (GENERIC)
    JMP int_generic_handler
;Interrupt 78 (GENERIC)
    JMP int_generic_handler
;Interrupt 79 (GENERIC)
    JMP int_generic_handler
;Interrupt 80 (GENERIC)
    JMP int_generic_handler
;Interrupt 81 (GENERIC)
    JMP int_generic_handler
;Interrupt 82 (GENERIC)
    JMP int_generic_handler
;Interrupt 83 (GENERIC)
    JMP int_generic_handler
;Interrupt 84 (GENERIC)
    JMP int_generic_handler
;Interrupt 85 (GENERIC)
    JMP int_generic_handler
;Interrupt 86 (GENERIC)
    JMP int_generic_handler
;Interrupt 87 (GENERIC)
    JMP int_generic_handler
;Interrupt 88 (GENERIC)
    JMP int_generic_handler
;Interrupt 89 (GENERIC)
    JMP int_generic_handler
;Interrupt 90 (GENERIC)
    JMP int_generic_handler
;Interrupt 91 (GENERIC)
    JMP int_generic_handler
;Interrupt 92 (GENERIC)
    JMP int_generic_handler
;Interrupt 93 (GENERIC)
    JMP int_generic_handler
;Interrupt 94 (GENERIC)
    JMP int_generic_handler
;Interrupt 95 (GENERIC)
    JMP int_generic_handler
;Interrupt 96 (GENERIC)
    JMP int_generic_handler
;Interrupt 97 (GENERIC)
    JMP int_generic_handler
;Interrupt 98 (GENERIC)
    JMP int_generic_handler
;Interrupt 99 (GENERIC)
    JMP int_generic_handler
;Interrupt 100 (GENERIC)
    JMP int_generic_handler
;Interrupt 101 (GENERIC)
    JMP int_generic_handler
;Interrupt 102 (GENERIC)
    JMP int_generic_handler
;Interrupt 103 (GENERIC)
    JMP int_generic_handler
;Interrupt 104 (GENERIC)
    JMP int_generic_handler
;Interrupt 105 (GENERIC)
    JMP int_generic_handler
;Interrupt 106 (GENERIC)
    JMP int_generic_handler
;Interrupt 107 (GENERIC)
    JMP int_generic_handler
;Interrupt 108 (GENERIC)
    JMP int_generic_handler
;Interrupt 109 (GENERIC)
    JMP int_generic_handler
;Interrupt 110 (GENERIC)
    JMP int_generic_handler
;Interrupt 111 (GENERIC)
    JMP int_generic_handler
;Interrupt 112 (GENERIC)
    JMP int_generic_handler
;Interrupt 113 (GENERIC)
    JMP int_generic_handler
;Interrupt 114 (GENERIC)
    JMP int_generic_handler
;Interrupt 115 (GENERIC)
    JMP int_generic_handler
;Interrupt 116 (GENERIC)
    JMP int_generic_handler
;Interrupt 117 (GENERIC)
    JMP int_generic_handler
;Interrupt 118 (GENERIC)
    JMP int_generic_handler
;Interrupt 119 (GENERIC)
    JMP int_generic_handler
;Interrupt 120 (GENERIC)
    JMP int_generic_handler
;Interrupt 121 (GENERIC)
    JMP int_generic_handler
;Interrupt 122 (GENERIC)
	JMP int_generic_handler
;Interrupt 123 (GENERIC)
    JMP int_generic_handler
;Interrupt 124 (GENERIC)
    JMP int_generic_handler
;Interrupt 125 (GENERIC)
    JMP int_generic_handler
;Interrupt 126 (GENERIC)
    JMP int_generic_handler
;Interrupt 127 (GENERIC)
    JMP int_generic_handler
;Interrupt 128 (GENERIC)
    JMP int_generic_handler
;Interrupt 129 (GENERIC)
    JMP int_generic_handler
;Interrupt 130 (GENERIC)
    JMP int_generic_handler
;Interrupt 131 (GENERIC)
    JMP int_generic_handler
;Interrupt 132 (GENERIC)
    JMP int_generic_handler
;Interrupt 133 (GENERIC)
    JMP int_generic_handler
;Interrupt 134 (GENERIC)
    JMP int_generic_handler
;Interrupt 135 (GENERIC)
    JMP int_generic_handler
;Interrupt 136 (GENERIC)
    JMP int_generic_handler
;Interrupt 137 (GENERIC)
    JMP int_generic_handler
;Interrupt 138 (GENERIC)
    JMP int_generic_handler
;Interrupt 139 (GENERIC)
    JMP int_generic_handler
;Interrupt 140 (GENERIC)
    JMP int_generic_handler
;Interrupt 141 (GENERIC)
    JMP int_generic_handler
;Interrupt 142 (GENERIC)
    JMP int_generic_handler
;Interrupt 143 (GENERIC)
    JMP int_generic_handler
;Interrupt 144 (GENERIC)
    JMP int_generic_handler
;Interrupt 145 (GENERIC)
    JMP int_generic_handler
;Interrupt 146 (GENERIC)
    JMP int_generic_handler
;Interrupt 147 (GENERIC)
    JMP int_generic_handler
;Interrupt 148 (GENERIC)
    JMP int_generic_handler
;Interrupt 149 (GENERIC)
    JMP int_generic_handler
;Interrupt 150 (GENERIC)
    JMP int_generic_handler
;Interrupt 151 (GENERIC)
    JMP int_generic_handler
;Interrupt 152 (GENERIC)
    JMP int_generic_handler
;Interrupt 153 (GENERIC)
    JMP int_generic_handler
;Interrupt 154 (GENERIC)
    JMP int_generic_handler
;Interrupt 155 (GENERIC)
    JMP int_generic_handler
;Interrupt 156 (GENERIC)
    JMP int_generic_handler
;Interrupt 157 (GENERIC)
    JMP int_generic_handler
;Interrupt 158 (GENERIC)
    JMP int_generic_handler
;Interrupt 159 (GENERIC)
    JMP int_generic_handler
;Interrupt 160 (GENERIC)
    JMP int_generic_handler
;Interrupt 161 (GENERIC)
    JMP int_generic_handler
;Interrupt 162 (GENERIC)
    JMP int_generic_handler
;Interrupt 163 (GENERIC)
    JMP int_generic_handler
;Interrupt 164 (GENERIC)
    JMP int_generic_handler
;Interrupt 165 (GENERIC)
    JMP int_generic_handler
;Interrupt 166 (GENERIC)
    JMP int_generic_handler
;Interrupt 167 (GENERIC)
    JMP int_generic_handler
;Interrupt 168 (GENERIC)
    JMP int_generic_handler
;Interrupt 169 (GENERIC)
    JMP int_generic_handler
;Interrupt 170 (GENERIC)
    JMP int_generic_handler
;Interrupt 171 (GENERIC)
    JMP int_generic_handler
;Interrupt 172 (GENERIC)
    JMP int_generic_handler
;Interrupt 173 (GENERIC)
    JMP int_generic_handler
;Interrupt 174 (GENERIC)
    JMP int_generic_handler
;Interrupt 175 (GENERIC)
    JMP int_generic_handler
;Interrupt 176 (GENERIC)
    JMP int_generic_handler
;Interrupt 177 (GENERIC)
    JMP int_generic_handler
;Interrupt 178 (GENERIC)
    JMP int_generic_handler
;Interrupt 179 (GENERIC)
    JMP int_generic_handler
;Interrupt 180 (GENERIC)
    JMP int_generic_handler
;Interrupt 181 (GENERIC)
    JMP int_generic_handler
;Interrupt 182 (GENERIC)
    JMP int_generic_handler
;Interrupt 183 (GENERIC)
    JMP int_generic_handler
;Interrupt 184 (GENERIC)
    JMP int_generic_handler
;Interrupt 185 (GENERIC)
    JMP int_generic_handler
;Interrupt 186 (GENERIC)
    JMP int_generic_handler
;Interrupt 187 (GENERIC)
    JMP int_generic_handler
;Interrupt 188 (GENERIC)
    JMP int_generic_handler
;Interrupt 189 (GENERIC)
    JMP int_generic_handler
;Interrupt 190 (GENERIC)
    JMP int_generic_handler
;Interrupt 191 (GENERIC)
    JMP int_generic_handler
;Interrupt 192 (GENERIC)
    JMP int_generic_handler
;Interrupt 193 (GENERIC)
    JMP int_generic_handler
;Interrupt 194 (GENERIC)
    JMP int_generic_handler
;Interrupt 195 (GENERIC)
    JMP int_generic_handler
;Interrupt 196 (GENERIC)
    JMP int_generic_handler
;Interrupt 197 (GENERIC)
    JMP int_generic_handler
;Interrupt 198 (GENERIC)
    JMP int_generic_handler
;Interrupt 199 (GENERIC)
    JMP int_generic_handler
;Interrupt 200 (GENERIC)
    JMP int_generic_handler
;Interrupt 201 (GENERIC)
    JMP int_generic_handler
;Interrupt 202 (GENERIC)
JMP int_generic_handler
	;Interrupt 203 ** DIV#0 **
    JMP int_div_zero
	;Interrupt 204 ** UNKNOWN INSTRUCTION **
    JMP int_unknown_instruction
	;Interrupt 205 ** RESERVED INSTRUCTION **
    JMP int_reserved_instruction
;Interrupt 206 (GENERIC)
JMP int_generic_handler
;Interrupt 207 (GENERIC)
JMP int_generic_handler
;Interrupt 208 (GENERIC)
JMP int_generic_handler
;Interrupt 209 (GENERIC)
 JMP int_generic_handler
;Interrupt 210 (GENERIC)
    JMP int_generic_handler
;Interrupt 211 (GENERIC)
    JMP int_generic_handler
;Interrupt 212 (GENERIC)
    JMP int_generic_handler
;Interrupt 213 (GENERIC)
    JMP int_generic_handler
;Interrupt 214 (GENERIC)
    JMP int_generic_handler
;Interrupt 215 (GENERIC)
    JMP int_generic_handler
;Interrupt 216 (GENERIC)
    JMP int_generic_handler
;Interrupt 217 (GENERIC)
    JMP int_generic_handler
;Interrupt 218 (GENERIC)
    JMP int_generic_handler
;Interrupt 219 (GENERIC)
    JMP int_generic_handler
;Interrupt 220 (GENERIC)
    JMP int_generic_handler
;Interrupt 221 (GENERIC)
    JMP int_generic_handler
;Interrupt 222 (GENERIC)
    JMP int_generic_handler
;Interrupt 223 (GENERIC)
    JMP int_generic_handler
;Interrupt 224 (GENERIC)
    JMP int_generic_handler
;Interrupt 225 (GENERIC)
    JMP int_generic_handler
;Interrupt 226 (GENERIC)
    JMP int_generic_handler
;Interrupt 227 (GENERIC)
    JMP int_generic_handler
;Interrupt 228 (GENERIC)
    JMP int_generic_handler
;Interrupt 229 (GENERIC)
    JMP int_generic_handler
;Interrupt 230 (GENERIC)
    JMP int_generic_handler
;Interrupt 231 (GENERIC)
    JMP int_generic_handler
;Interrupt 232 (GENERIC)
    JMP int_generic_handler
;Interrupt 233 (GENERIC)
    JMP int_generic_handler
;Interrupt 234 (GENERIC)
    JMP int_generic_handler
;Interrupt 235 (GENERIC)
    JMP int_generic_handler
;Interrupt 236 (GENERIC)
    JMP int_generic_handler
;Interrupt 237 (GENERIC)
    JMP int_generic_handler
;Interrupt 238 (GENERIC)
    JMP int_generic_handler
;Interrupt 239 (GENERIC)
    JMP int_generic_handler
;Interrupt 240 (GENERIC)
    JMP int_generic_handler
;Interrupt 241 (GENERIC)
    JMP int_generic_handler
;Interrupt 242 (GENERIC)
    JMP int_generic_handler
;Interrupt 243 (GENERIC)
	JMP int_generic_handler 
;Interrupt 244 (GENERIC)
    JMP int_generic_handler
;Interrupt 245 (GENERIC)
    JMP int_generic_handler
;Interrupt 246 (GENERIC)
    JMP int_generic_handler
;Interrupt 247 (GENERIC)
    JMP int_generic_handler
;Interrupt 248 (GENERIC)
    JMP int_generic_handler
;Interrupt 249 (GENERIC)
    JMP int_generic_handler
;Interrupt 250 (GENERIC)
    JMP int_generic_handler
;Interrupt 251 (GENERIC)
    JMP int_generic_handler
;Interrupt 252 (GENERIC)
    JMP int_generic_handler
;Interrupt 253 (GENERIC)
    JMP int_generic_handler
;Interrupt 254 (GENERIC)
    JMP int_generic_handler
;Interrupt 255 (GENERIC)
    JMP int_generic_handler
;Interrupt 256 (GENERIC)
    JMP int_generic_handler
;Interrupt 257 (GENERIC)
    JMP int_generic_handler
;Interrupt 258 (GENERIC)
    JMP int_generic_handler
;Interrupt 259 (GENERIC)
    JMP int_generic_handler
;Interrupt 260 (GENERIC)
    JMP int_generic_handler
;Interrupt 261 (GENERIC)
    JMP int_generic_handler
;Interrupt 262 (GENERIC)
    JMP int_generic_handler
;Interrupt 263 (GENERIC)
    JMP int_generic_handler
;Interrupt 264 (GENERIC)
    JMP int_generic_handler
;Interrupt 265 (GENERIC)
    JMP int_generic_handler
;Interrupt 266 (GENERIC)
    JMP int_generic_handler
;Interrupt 267 (GENERIC)
    JMP int_generic_handler
;Interrupt 268 (GENERIC)
    JMP int_generic_handler
;Interrupt 269 (GENERIC)
    JMP int_generic_handler
;Interrupt 270 (GENERIC)
    JMP int_generic_handler
;Interrupt 271 (GENERIC)
    JMP int_generic_handler
;Interrupt 272 (GENERIC)
    JMP int_generic_handler
;Interrupt 273 (GENERIC)
    JMP int_generic_handler
;Interrupt 274 (GENERIC)
    JMP int_generic_handler
;Interrupt 275 (GENERIC)
    JMP int_generic_handler
;Interrupt 276 (GENERIC)
    JMP int_generic_handler
;Interrupt 277 (GENERIC)
    JMP int_generic_handler
;Interrupt 278 (GENERIC)
    JMP int_generic_handler
;Interrupt 279 (GENERIC)
    JMP int_generic_handler
;Interrupt 280 (GENERIC)
    JMP int_generic_handler
;Interrupt 281 (GENERIC)
    JMP int_generic_handler
;Interrupt 282 (GENERIC)
    JMP int_generic_handler
;Interrupt 283 (GENERIC)
    JMP int_generic_handler
;Interrupt 284 (GENERIC)
    JMP int_generic_handler
;Interrupt 285 (GENERIC)
    JMP int_generic_handler
;Interrupt 286 (GENERIC)
    JMP int_generic_handler
;Interrupt 287 (GENERIC)
    JMP int_generic_handler
;Interrupt 288 (GENERIC)
    JMP int_generic_handler
;Interrupt 289 (GENERIC)
    JMP int_generic_handler
;Interrupt 290 (GENERIC)
    JMP int_generic_handler
;Interrupt 291 (GENERIC)
    JMP int_generic_handler
;Interrupt 292 (GENERIC)
    JMP int_generic_handler
;Interrupt 293 (GENERIC)
    JMP int_generic_handler
;Interrupt 294 (GENERIC)
    JMP int_generic_handler
;Interrupt 295 (GENERIC)
    JMP int_generic_handler
;Interrupt 296 (GENERIC)
    JMP int_generic_handler
;Interrupt 297 (GENERIC)
    JMP int_generic_handler
;Interrupt 298 (GENERIC)
    JMP int_generic_handler
;Interrupt 299 (GENERIC)
    JMP int_generic_handler
;Interrupt 300 (GENERIC)
    JMP int_generic_handler
;Interrupt 301 (GENERIC)
    JMP int_generic_handler
;Interrupt 302 (GENERIC)
    JMP int_generic_handler
;Interrupt 303 (GENERIC)
    JMP int_generic_handler
;Interrupt 304 (GENERIC)
    JMP int_generic_handler
;Interrupt 305 (GENERIC)
    JMP int_generic_handler
;Interrupt 306 (GENERIC)
    JMP int_generic_handler
;Interrupt 307 (GENERIC)
    JMP int_generic_handler
;Interrupt 308 (GENERIC)
    JMP int_generic_handler
;Interrupt 309 (GENERIC)
    JMP int_generic_handler
;Interrupt 310 (GENERIC)
    JMP int_generic_handler
;Interrupt 311 (GENERIC)
    JMP int_generic_handler
;Interrupt 312 (GENERIC)
    JMP int_generic_handler
;Interrupt 313 (GENERIC)
    JMP int_generic_handler
;Interrupt 314 (GENERIC)
    JMP int_generic_handler
;Interrupt 315 (GENERIC)
    JMP int_generic_handler
;Interrupt 316 (GENERIC)
    JMP int_generic_handler
;Interrupt 317 (GENERIC)
    JMP int_generic_handler
;Interrupt 318 (GENERIC)
    JMP int_generic_handler
;Interrupt 319 (GENERIC)
    JMP int_generic_handler
;Interrupt 320 (GENERIC)
    JMP int_generic_handler
;Interrupt 321 (GENERIC)
    JMP int_generic_handler
;Interrupt 322 (GENERIC)
    JMP int_generic_handler
;Interrupt 323 (GENERIC)
    JMP int_generic_handler
;Interrupt 324 (GENERIC)
    JMP int_generic_handler
;Interrupt 325 (GENERIC)
    JMP int_generic_handler
;Interrupt 326 (GENERIC)
    JMP int_generic_handler
;Interrupt 327 (GENERIC)
    JMP int_generic_handler
;Interrupt 328 (GENERIC)
    JMP int_generic_handler
;Interrupt 329 (GENERIC)
    JMP int_generic_handler
;Interrupt 330 (GENERIC)
    JMP int_generic_handler
;Interrupt 331 (GENERIC)
    JMP int_generic_handler
;Interrupt 332 (GENERIC)
    JMP int_generic_handler
;Interrupt 333 (GENERIC)
    JMP int_generic_handler
;Interrupt 334 (GENERIC)
    JMP int_generic_handler
;Interrupt 335 (GENERIC)
    JMP int_generic_handler
;Interrupt 336 (GENERIC)
    JMP int_generic_handler
;Interrupt 337 (GENERIC)
    JMP int_generic_handler
;Interrupt 338 (GENERIC)
    JMP int_generic_handler
;Interrupt 339 (GENERIC)
    JMP int_generic_handler
;Interrupt 340 (GENERIC)
    JMP int_generic_handler
;Interrupt 341 (GENERIC)
    JMP int_generic_handler
;Interrupt 342 (GENERIC)
    JMP int_generic_handler
;Interrupt 343 (GENERIC)
    JMP int_generic_handler
;Interrupt 344 (GENERIC)
    JMP int_generic_handler
;Interrupt 345 (GENERIC)
    JMP int_generic_handler
;Interrupt 346 (GENERIC)
    JMP int_generic_handler
;Interrupt 347 (GENERIC)
    JMP int_generic_handler
;Interrupt 348 (GENERIC)
    JMP int_generic_handler
;Interrupt 349 (GENERIC)
    JMP int_generic_handler
;Interrupt 350 (GENERIC)
    JMP int_generic_handler
;Interrupt 351 (GENERIC)
    JMP int_generic_handler
;Interrupt 352 (GENERIC)
    JMP int_generic_handler
;Interrupt 353 (GENERIC)
    JMP int_generic_handler
;Interrupt 354 (GENERIC)
    JMP int_generic_handler
;Interrupt 355 (GENERIC)
    JMP int_generic_handler
;Interrupt 356 (GENERIC)
    JMP int_generic_handler
;Interrupt 357 (GENERIC)
    JMP int_generic_handler
;Interrupt 358 (GENERIC)
    JMP int_generic_handler
;Interrupt 359 (GENERIC)
    JMP int_generic_handler
;Interrupt 360 (GENERIC)
    JMP int_generic_handler
;Interrupt 361 (GENERIC)
    JMP int_generic_handler
;Interrupt 362 (GENERIC)
    JMP int_generic_handler
;Interrupt 363 (GENERIC)
    JMP int_generic_handler
;Interrupt 364 (GENERIC)
    JMP int_generic_handler
	;-----------------------------------------------


	start_os:

	;------------------------------- MAIN SHELL LOOP -------------------------------
	loop_shell:
	JSR new_line
	JSR view_prompt

	
	JSR read_line_ser2

	;IS only enter?
	LD.T R59,10008(R0)
	JEQI R59,#0,loop_shell

	;new line
	JSR new_line

	JSR str_tokenizer 
	ANYI R3,R0,#10800 

	

	LEA R4,shell_cmd_version
	JSR str_cmp
	JEQI R59,#1,cmd_version

	LEA R4,shell_cmd_cls
	JSR str_cmp
	JEQI R59,#1,cmd_cls

	LEA R4,shell_cmd_run
	JSR str_cmp
	JEQI R59,#1,cmd_run

	LEA R4,shell_cmd_list
	JSR str_cmp
	JEQI R59,#1,cmd_list



	;if here the command is not recognized.
	LEA R3,str_cmd_unk
	JSR println

	JMP loop_shell
	;--------------------------------------------------------------------------------


	
	;-----------------------------------------------
	main_exit:
	HLT 
	;-----------------------------------------------


	;-------------------
	; ANSI Clear Screen
	;
	; input:	R7  Serial Port
	;			
	;-------------------

	ANSI_clear_screen:
	;PROLOGUE
	PUSH R12
	;Insert return value on the stack
	PUSH R26

	ANYI R12,R0,#27	;ESC
	OUT 0(R7),R12
	ANYI R12,R0,#91	;[
	OUT 0(R7),R12
	ANYI R12,R0,#50	;2
	OUT 0(R7),R12
	ANYI R12,R0,#74	;J
	OUT 0(R7),R12

	ANYI R12,R0,#27	;ESC
	OUT 0(R7),R12
	ANYI R12,R0,#91	;[
	OUT 0(R7),R12
	ANYI R12,R0,#72	;H
	OUT 0(R7),R12

	;EPILOGUE
	POP.W R26
	POP.W R12
	JR R26
	;------------------------------ END ANSI_clear_screen


	;-------------------
	; ANSI Write Color
	;
	; input:	R7  Serial Port
	;			R27 ANSI Foreground Color
	;			R28 ANSI BAckground Color
	;			R29  String
	;-------------------
	ANSI_write_color:
	;PROLOGUE
	PUSH R3
	PUSH R5
	PUSH R6
	PUSH R12
	;Insert return value on the stack
	PUSH R26

	ANYI R12,R0,#27	;ESC
	OUT 0(R7),R12
	ANYI R12,R0,#91	;[
	OUT 0(R7),R12
	

	
	; -- Foreground (R27) Conversion in string
	ANY R5,R0,R27
	ANYI R6,R0,#15000	;address of buffeas string result
	JSR integer_to_string

	ANYI R6,R0,#15000
	
	LD R12,0(R6)	;first digit
	OUT 0(R7),R12

	ADDI R6,R6,#4	
	LD R12,0(R6)	;second digit
	OUT 0(R7),R12

	ANYI R12,R0,#59
	OUT 0(R7),R12	; ; char


	; -- Background (R28) Conversion in string
	ANY R5,R0,R28
	ANYI R6,R0,#15000	;address of buffeas string result
	JSR integer_to_string

	ANYI R6,R0,#15000

	LD R12,0(R6)	;first digit
	OUT 0(R7),R12

	ADDI R6,R6,#4	
	LD R12,0(R6)	;second digit
	OUT 0(R7),R12

	ANYI R12,R0,#109;m
	OUT 0(R7),R12

	;now write the string (in R29 there is the Address of string)
	ANY R3,R0,R29
	JSR print

	;Reset ANSI color
	ANYI R12,R0,#27	;ESC
	OUT 0(R7),R12
	ANYI R12,R0,#91	;[
	OUT 0(R7),R12
	ANYI R12,R0,#48	;0
	OUT 0(R7),R12
	ANYI R12,R0,#109;m
	OUT 0(R7),R12


	;EPILOGUE
	POP.W R26
	POP.W R12
	POP.W R6
	POP.W R5
	POP.W R3
	
	JR R26

	;------------------------------ END ANSI_write_color


	;-------------------
	; NEW LINE
	;
	; input:	R7  Serial Port
	;-------------------
	
	new_line:
	;PROLOGUE
	PUSH R4
	;Insert return value on the stack
	PUSH R26

	;new line
	ANYI R4,R0,#10	;<LF>
	OUT 0(R7),R4
	ANYI R4,R0,#13	;<CR>
	OUT 0(R7),R4 

	;EPILOGUE
	POP.W R26
	POP.W R4
	
	JR R26

	;------------------------------ END new_line



	;-------------------
	; PRINT INTEGER 1.2 (no divide procedure but DIV instruction)
	; input:	R5 24 trit Integer
	;			R7 Serial Port
	;-------------------
	
	print_integer:
	;PROLOGUE
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R10
	PUSH R11
	PUSH R12
	;Insert return value on the stack
	PUSH R26


	ANYI R3,R0,#0 ; Set as positive number
	JBE R5,R0,print_integer_start
	ANYI R3,R0,#1 ; Is a negative number
	STI R5,R5



	print_integer_start:
	ANYI R4,R0,#0		;contatore cifre

	print_integer_loop:
	ANY R10,R0,R5
	ANYI R11,R0,#10	;divisore
	DIV  R10,R12,R11,R10

	
	ADDI R10,R10,#48	;add 48 
	PUSH.W R10

	ADDI R4,R4,#1	;counter
	ANY R5,R0,R12
	JB R12,R0,print_integer_loop

	;is a positive number?
	JEQ R3,R0,view_cifra
	;is is a negative number, I write '-'
	ANYI R6,R0,#45	; '-' char
	OUT 0(R7),R6

	view_cifra:
	POP.W R6
	OUT 0(R7),R6


	ADDI R4,R4,#-1
	JB R4,R0,view_cifra
	
	;EPILOGUE
	POP.W R26
	POP.W R12
	POP.W R11
	POP.W R10
	POP.W R6
	POP.W R5
	POP.W R4
	POP.W R3

	JR R26
	;---------- END PRINT INTEGER

	;-------------------
	; INTEGER TO STRING
	; input:	R5 24 trit Integer
	;			R6 string buffer
	;-------------------
	
	integer_to_string:
	;PROLOGUE
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R10
	PUSH R11
	PUSH R12
	PUSH R13
	;Insert return value on the stack
	PUSH R26


	ANYI R3,R0,#0 ; Set as positive number
	JBE R5,R0,integer_to_string_start
	ANYI R3,R0,#1 ; Is a negative number
	STI R5,R5

	integer_to_string_start:
	ANYI R4,R0,#0		;contatore cifre

	integer_to_string_loop:
	ANY R10,R0,R5
	ANYI R11,R0,#10	;divisore
	DIV R10,R12,R11,R10	;R10 = R10 rem R11   R12 = R10/R11

	ADDI R10,R10,#48	;aggiungo 48 al resto
	PUSH.W R10

	ADDI R4,R4,#1	;contatore cifre
	ANY R5,R0,R12
	JB R12,R0,integer_to_string_loop


	;is a positive number?
	JEQ R3,R0,integer_to_string_view_cifra
	;is is a negative number, I write '-'
	ANYI R13,R0,#45	; '-' char
	ST 0(R6),R13
	ADDI R6,R6,#4

	integer_to_string_view_cifra:
	POP.W R13
	ST 0(R6),R13
	ADDI R6,R6,#4


	ADDI R4,R4,#-1
	JB R4,R0,integer_to_string_view_cifra
	
	ST 0(R6),R0
		
	;EPILOGUE
	POP.W R26
	POP.W R13
	POP.W R12
	POP.W R11
	POP.W R10
	POP.W R6
	POP.W R5
	POP.W R4
	POP.W R3

	JR R26
	;---------- END INTEGER TO STRING


	;-------------------
	; PRINT INTEGER TERNARY
	; input:	R10 24 trit Integer
	;			R15 numbers of trit to view
	;			R7  Serial Port
	;-------------------
	
	print_integer_ternary:
	;PROLOGUE
	PUSH R10
	PUSH R11
	PUSH R12
	PUSH R14
	PUSH R15
	;Insert return value on the stack
	PUSH R26

	ANYI R14,R0,#1	;R14 = loop counter

	ANYI R11,R0,#1	; Positive Mask

	pit_loop:
	MSKP R12,R11,R10
	JEQI R12,#1,pit_sign_plus
	JEQI R12,#-1,pit_sign_minus
	ANYI R12,R0,#48	;'0'
	JMP pit_exit
	pit_sign_plus:
	ANYI R12,R0,#43	;'+'
	JMP pit_exit
	pit_sign_minus:
	ANYI R12,R0,#45	;'-'
		
	pit_exit:

	PUSH R12

	ASHI R10,R10,#1

	ADDI R14,R14,#1
	JBE R15,R14,pit_loop

	;view from stack
	ANYI R14,R0,#1	;R14 = loop counter
	pit_l_stack:
	POP R12
	OUT SERIAL_PORT_2(r0),R12
	ADDI R14,R14,#1
	JBE R15,R14,pit_l_stack

	;EPILOGUE
	POP.W R26
	POP.W R15
	POP.W R14
	POP.W R12
	POP.W R11
	POP.W R10
	
	JR R26
	;-------------------------- END print_integer_ternary


	
	; ---   PRINTLN  1.2 ----------------------------------
	; input:	R3 Address of first character of the string
	;			R7 Serial Port
	;---------------------------------------------------
	println:
	;save registers on stack
	PUSH R4
	PUSH R26

	JSR print
	

	ANYI R4,R0,#10	;<LF>
	OUT 0(R7),R4
	ANYI R4,r0,#13	;<CR>
	OUT 0(R7),R4 

	POP R26
	POP R4
	JR R26	;rts


	

    ; ---   PRINT 1.3 ------------------------------------
	; Print string on serial port
	; Each character is packed in 6 trits
	; load an "packaging" string (4 char in one word)
	; and in memory test for 0 (end of string) any chars
	; input:	R3 Address of first character of the string
	;			R7 Serial Port
	;------------------------------------------------------
	print:
	PUSH.W R3
	PUSH.W R2
	PUSH.W R9
	PUSH.W R22
	;Insert return value on the stack
	PUSH.W R26

	ANYI R22,R0,#364	; MASK ++++++
		
	loop_print:
	LD.W R2,0(R3)	

	MSKP R9,R22,R2
	JEQ R9,R0,exit_print
	OUT 0(R7),R9

	ROTI R2,R2,#6
	MSKP R9,R22,R2
	JEQ R9,R0,exit_print
	OUT 0(R7),R9

	ROTI R2,R2,#6
	MSKP R9,R22,R2
	JEQ R9,R0,exit_print
	OUT 0(R7),R9

	ROTI R2,R2,#6
	MSKP R9,R22,R2
	JEQ R9,R0,exit_print
	OUT 0(R7),R9

	;next word
	ADDI R3,R3,#4
	JMP loop_print

	exit_print:
	POP.W R26
	POP.W R22
	POP.W R9
	POP.W R2
	POP.W R3
	JR R26	;rts




	;----------------------------
	; POW
	;
	;Input: R10 base, R11 exp
	;Output: R12 = R10^R11 
	;---------------------------
	pow:
	;PROLOGUE
	PUSH R10
	PUSH R11
	PUSH R27
	PUSH R28
	;Insert return value on the stack
	PUSH.W R26

	ANY R27,R0,R10
	ANYI R28,R0,#1

	loop_pow:
	MUL R27,R0,R27,R10; R27 = R27*R10
	ADDI R28,R28,#1
	JB R11,R28,loop_pow

	exit_pow:
	ANY R12,R0,R27
	
	;EPILOGUE
	POP.W R26
	POP.W R28
	POP.W R27
	POP.W R11
	POP.W R10

	JR R26


	;-------------------
	; Read Word from SD
	;	read a word (24 trit) from the standard SPI SD Card (on GRAM 1.3)
	;
	; input:	R15 address of word
	; output:	R16 word read
	;-------------------
	read_word_SD:
	;PROLOGUE
	PUSH.W R26

	OUT SDC0_WORD_ADDRESS(R0),R15	;Word Address to read

	ANYI R17,R0,#SDC_CMD_READ	;COMMAND 1: READ
	OUT SDC0_COMMAND(R0),R17
	;The word read in R16
	IN R16,SDC0_WORD_READ(R0)


	;EPILOGUE
	POP.W R26
	JR R26



	

	


	



	;------------  print_spaces -----------
	; INPUT 
	; R60 numbers of spaces
	print_spaces:
	;PROLOGUE
	PUSH R60
	PUSH R61
	;Insert return value on the stack
	PUSH.W R26

	ANYI R61,R0,#32	;space

	loop_print_spaces:
	JEQ R60,R0,exit_print_spaces
	SUBI R60,R60,#1
	OUT 0(R7),R61
	JMP loop_print_spaces
	
	exit_print_spaces:
	;EPILOGUE
	POP.W R26
	POP.W R61
	POP.W R60
	JR R26

	;------------  str_tokenizer -----------
	; INPUT 
	; string to tokenizer @10008
	; OUTPUT
	; 1st token @10800
	; 2nd token @10896
	str_tokenizer:
	;PROLOGUE
	PUSH.W R60
	PUSH.W R61
	PUSH.W R62
	PUSH.W R63
	PUSH.W R64
	;Insert return value on the stack
	PUSH.W R26

	ANYI R60,R0,#10008	;address of first char

	ANYI R62,R0,#10800	;address of first substring
	ANY  R64,R0,R62		;first token block

	loop_str_tokenizer:
	LD.T R61,0(R60)

	JEQI R61,#32,str_tokenizer_is_space		;SPACE
	JEQI R61,#9,str_tokenizer_is_space		;TAB
	;JEQI R61,#10,exit_str_tokenizer		;LF
	;JEQI R61,#13,exit_str_tokenizer		;CR
	JEQ R61,R0,exit_str_tokenizer		;NUL

	;If here, I have a normal char
	ANYI R63,R0,R0	;signal thath I have now a char
	ST.T 0(R62),R61
	ADDI R62,R62,#1	;next char in this token
	
	
	INC R60	;next char in main string
	JMP loop_str_tokenizer

	str_tokenizer_is_space:
	ADDI R60,R60,#1
	JEQ R63,R0,next_token
	JMP loop_str_tokenizer

	next_token:
	ST.T 0(R62),R0	;terminate currently token
	ANYI R63,R0,#1
	ADDI R64,R64,#96	;4*24char
	ANY R62,R0,R64
	JMP loop_str_tokenizer


	exit_str_tokenizer:
	ST.T 0(R62),R0	;terminate currently token
	;EPILOGUE
	POP.W R26
	POP.W R64
	POP.W R63
	POP.W R62
	POP.W R61
	POP.W R60
	JR R26




	;------------  View Prompt -----------
	view_prompt:
	;PROLOGUE
	PUSH R3
	;Insert return value on the stack
	PUSH.W R26

	LEA R3,str_prompt
	JSR print
	
	;EPILOGUE
	POP.W R26
	POP.W R3
	JR R26


	;------------Read_Line_ser1-------------------------------------

	read_line_ser1:
	PUSH.W R10
	PUSH.W R26

	; Initialize variables (the first string char is at 10008)
	ST 10000(R0),R0           ; flag_line_ready = 0
	ST 10004(R0),R0           ; string length

	OUT 55(R0),R0             ; attiva interrupt serial1

	wait_for_line_ser1:
	LD R10,10000(R0)
	JEQ R10,R0,wait_for_line_ser1 ; aspetta che flag diventi 1

  
	POP.W R26
	POP.W R10
	JR R26
	;---------------------------------------------------------------

	;------------Read_Line_ser2-------------------------------------

	read_line_ser2:
	PUSH.W R10
	PUSH.W R26

	; Initialize variables (the first string char is at 10008)
	ST 10000(R0),R0           ; flag_line_ready = 0
	ST 10004(R0),R0           ; string length

	OUT 65(R0),R0             ; attiva interrupt serial2

	wait_for_line:
	LD R10,10000(R0)
	JEQ R10,R0,wait_for_line ; aspetta che flag diventi 1

  
	POP.W R26
	POP.W R10
	JR R26
	;---------------------------------------------------------------
	


	check_computer:
	;PROLOGUE
	PUSH.W R20
	PUSH.W R21
	PUSH.W R22
	;Insert return value on the stack
	PUSH.W R26

	LEA R3,str_computer_type
	JSR print
	;Read motherboard string from address 10d
	IN R20,10(R0)
	ANY R21,R0,R20	
	
	;search for brand (first 4 trit) -> R22
	ANYI R22,R0,#40	; ++++
	MSKP R22,R22,R21

	;Search for Model -> R23
	ANY R21,R0,R20
	ANYI R23,R0,#13	; +++
	ASHI R21,R21,#4
	MSKP R23,R23,R21

	;Search for version -> R24
	ANY  R21,R0,R20
	ANYI R24,R0,#13	; +++
	ASHI R21,R21,#7
	MSKP R24,R24,R21

	
	

	;Brand selector
	; Is MOS/TCS?
	JEQI R22,#28,cc_mos

	;If Here the computer brand is unknown!
	LEA R3,str_unk
	JSR print
	JMP exit_cc

	;---------  Brand MOS/TCS
	cc_mos:
	LEA R3,str_brand_MOS
	JSR print
	;Model?
	JEQI R23,#-13,cc_mos_GRAM
	JMP exit_cc
	;------------- GargantuRAM
	cc_mos_GRAM:
	LEA R3,str_model_gram
	JSR print
	;-------- GargantuRAM VERSION
	JEQI R24,#-13,cc_mos_gram_one_point_three
	JEQI R24,#-12,cc_mos_gram_one_point_four
	JEQI R24,#-11,cc_mos_gram_one_point_fivePRE
	JMP exit_cc
	cc_mos_gram_one_point_three:
	LEA R3,str_one_point_three
	JSR print
	JMP exit_cc
	cc_mos_gram_one_point_four:
	LEA R3,str_one_point_four
	JSR print
	JMP exit_cc
	cc_mos_gram_one_point_fivePRE:
	LEA R3,str_one_point_fivePRE
	JSR print
	
	exit_cc:
	JSR new_line
	POP.W R26
	POP.W R22
	POP.W R21
	POP.W R20
	JR R26

	
	;---------------------------- VERSION
	cmd_version:
	;PROLOGUE
	
	LEA R3,str_version
	JSR println

	JMP loop_shell
	;---------------------------- /VERSION/

	;---------------------------- CLS
	cmd_cls:
	JSR ANSI_clear_screen
	JMP loop_shell
	;---------------------------- /CLS/


	;---------------------------- RUN
	cmd_run:
	ANYI R65,R0,#0	;first item
	;what is the program name?
	ANYI R3,R0,#10896	;first args
	JSR println

	cmd_run_loop:
	JSR SD_load_item_name

	;check if I reached the end of the directory
	LD R16,20000(R0)
		
	ANYI R22,R0,#364	; ++++++
	MSKP R23,R22,R16
	JEQI R23,#3,not_found_program

	;here I have in [20000] the string to compare readed from SD archaic File System 
	;and in [10896] the string typed by user
	;now I compare the two strings
	JSR str_compare_strange


	JEQI R31,#1,found_program

	;If I are here then update index and try next item
	ADDI R65,R65,#1	;next item
	JMP cmd_run_loop
	

	not_found_program:
	LEA R3,str_file_not_found
	JSR println
	JMP loop_shell


	found_program:
	LEA R3,str_file_found
	JSR print
	ANY R5,R0,R65	;view index of found program
	JSR print_integer
	JSR new_line


	;Now I search for the start sector of index item R65
	JSR find_start_sector
	;Now I have here in R29 the initial sector of program to load
	JSR find_numbers_of_sectors
	;And now I have here the numbers of sectors in R35!

	JSR load_prg_raw
	;run new program in USER mode
	ANYI R17,R0,#15000	;15000 = start address of loaded program
	PUSH.W R17
	CHST #4		;4 = USER MODE 
	RTI


	;---------------------------- /RUN/

	;---------------------------- LIST
	cmd_list:

	JSR new_line
	LEA R3,str_dir_sd
	JSR println
	JSR new_line

	ANYI R30,R0,#68000	;68000 = sector 200 (200*4*85)
	ANY R15,R0,R30	
	ANY R60,R0,R0		;char counter to zero
	ANYI R22,R0,#364	; ++++++

	loop_cmd_list_items:
	;variables for loop external (15 word to read for names)
	ANY R19,R0,R0
	ANYI R20,R0,#15

	loop_cmd_list:
	ANY R17,R0,R0
	ANYI R18,R0,#4
	
	JSR read_word_SD
	
	loop_cmd_list_internal:
	
	MSKP R23,R22,R16
	JEQI R23,#3,exit_listing
	JEQ R23,R0,exit_cmd_list

	OUT 0(R7),R23		;print this char
	ADDI R60,R60,#1		;count char

	ADDI R17,R17,#1
	ROTI R16,R16,#6
	JBE R18,R17,loop_cmd_list_internal

	;next word address...
	ADDI R15,R15,#4

	ADDI R19,R19,#1
	JBE R20,R19,loop_cmd_list

	exit_cmd_list:

	STI R60,R60
	ADDI R60,R60,#35	
	JSR print_spaces
	
	;here I read the word for the initial sector
	ANY R15,R0,R30
	ADDI R15,R15,#60; after 60 char (60 = 15char*4tryte)

	JSR read_word_SD
	;Print the initial sector
	ANY R5,R0,R16
	JSR print_integer
		
	;Now read the last word
	ADDI R15,R15,#4
	JSR read_word_SD

	;extract the number of sectors
	ASHI R16,R16,#12
	;and print it...
	ANYI R25,R0,#9	; Horizontal TAB
	OUT 0(R7),R25
	ANY R5,R0,R16
	JSR print_integer

	;next item...
	JSR new_line
	ADDI R15,R15,#4	;next Item
	ANY R30,R0,R15
	ANY R60,R0,R0		;char counter to zero
	JMP loop_cmd_list_items

	exit_listing:



	JMP loop_shell
	;---------------------------- /LIST/

	;----------------- SD_load_item_name --------------------------
	;Input:		R65 Item number
	;			
	SD_load_item_name:
	PUSH.W R15
	PUSH.W R16
	PUSH.W R66
	PUSH.W R67
	PUSH.W R68
	PUSH.W R69
	;Insert return value on the stack
	PUSH.W R26

	ANYI R66,R0,#68000	;base of sector 200
	ANYI R67,R0,#20000	;memory base for string
	ANYI R68,R0,#364	; ++++++
	ANYI R69,R0,#68		;number of address of one item


	MUL R15,R70,R69,R65	;Item*base   in R15 there is the address of word to read
	ADD R15,R15,R66		;Base of this item


	loop_SD_load_item_name:
	JSR read_word_SD
	;save this word in memory [20000]
	ST 0(R67),R16

	ANY R33,R0,R15	;Save R15
	
	
	;is the last word of this string?
	MSKP R16,R68,R16	;first (LST) 6 trit, are zero?
	JEQ R16,R0,exit_SD_load_item_name
	ADDI R15,R33,#4	;next word to read
	ADDI R67,R67,#4	;next word in memory
	JMP loop_SD_load_item_name

	exit_SD_load_item_name:
	;Epiloque
	POP.W R26
	POP.W R69
	POP.W R68
	POP.W R67
	POP.W R66
	POP.W R16
	POP.W R15
	JR R26
	;---------------------------------------------------------

	;------------- str_compare_strange -------------
	; Input:		[20000] string from SD archaic FS
	;				[10896] string typed by user
	; Output:		R31 = 1 same, 0 different
	str_compare_strange:
	;PROLOGUE
	PUSH.W R3
	PUSH.W R6
	PUSH.W R8
	PUSH.W R9
	PUSH.W R22
	PUSH.W R30
	;Insert return value on the stack
	PUSH.W R26

	ANYI R30,R0,#20000
	ANYI R22,R0,#364	; MASK ++++++

    loop_compare_strange:

	LD.W R6,0(R30)	
	LD.W R8,0(R3)

	MSKP R9,R22,R6
	MSKP R10,R22,R8
	JNE R9,R10,exit_different
	JEQ R9,R0,exit_ok

	ROTI R6,R6,#6
	ROTI R8,R8,#6
	MSKP R9,R22,R6
	MSKP R10,R22,R8
	JNE R9,R10,exit_different
	JEQ R9,R0,exit_ok

	ROTI R6,R6,#6
	ROTI R8,R8,#6
	MSKP R9,R22,R6
	MSKP R10,R22,R8
	JNE R9,R10,exit_different
	JEQ R9,R0,exit_ok

	ROTI R6,R6,#6
	ROTI R8,R8,#6
	MSKP R9,R22,R6
	MSKP R10,R22,R8
	JNE R9,R10,exit_different
	JEQ R9,R0,exit_ok


	;----
	ADDI R3,R3,#4		;next word
	ADDI R30,R30,#4	    ;next word
	JMP loop_compare_strange
	
	exit_different:
	ANY R31,R0,R0	;different
	JMP exit_cmp_strange
	
	exit_ok:
	ANYI R31,R0,#1

	exit_cmp_strange:
	;Epiloque
	POP.W R26
	POP.W R30
	POP.W R22
	POP.W R9
	POP.W R8
	POP.W R6
	POP.W R3
	JR R26
	;--------- /str_compare_strange/ -----------


	;----------------- Load_prg_raw --------------------------
	;Input:		R29 Sector SD Card
	;			R35 number of Sectors
	load_prg_raw:
	PUSH.W R30
	PUSH.W R31
	PUSH.W R32
	;Insert return value on the stack
	PUSH.W R26

	ANYI R30,R0,#85
	MUL R32,R31,R30,R29

	ANYI R30,R0,#4
	MUL R32,R31,R32,R30

	;Calculate the number of word (1 sector = 85 word)
	ANYI R30,R0,#85
	MUL R35,R0,R35,R30
	

	ANYI R31,R0,#0			;loop var
	ANYI R33,R0,#15000		;Memory Base
	
	loop_load_prg_raw:
	ANY R15,R0,R32
	JSR read_word_SD
	ST 0(R33),R16


	ADDI R32,R32,#4	;Address SD
	ADDI R33,R33,#4	;Address Memory

	ADDI R31,R31,#1
	JB R35,R31,loop_load_prg_raw


	;Epiloque
	POP.W R26
	POP.W R32
	POP.W R31
	POP.W R30
	JR R26

	;----------------- /Load_prg_raw/ --------------------------




	;----------------- STR-CMP--------------------------
	; Input: R3 address of first string
	;        R4 address of second string
	; Output: R59 = 1 equal, 0 different
	;
	; This procudure takes two strings packed in 4 char for tryte
	; It compares 4 char at time because the read of the compare string 
	; for shell's command is in SDCArd and it is not possible to read char by char 
	; directly from SD Card (not allowed address not multiple of 4!)
	str_cmp:
	;PROLOGUE
	PUSH.W R3
	PUSH.W R4
	PUSH.W R8
	PUSH.W R9
	PUSH.W R22
	PUSH.W R55
	PUSH.W R56
	;Insert return value on the stack
	PUSH.W R26

	ANYI R59,R0,#0		;default return value = 0 = different!
	ANYI R22,R0,#364	; MASK ++++++

	str_cmp_main_loop:
	LD.W R55,0(R3)	; first 4 chars
	LD.W R56,0(R4)	; first 4 char

	
	;---first char comparison
	MSKP R8,R22,R55
	MSKP R9,R22,R56
	JNE R8,R9,str_cmp_exit
	JEQ R8,R0,str_cmp_exit_eq

	ROTI R55,R55,#6
	ROTI R56,R56,#6

	;---second char comparison
	MSKP R8,R22,R55
	MSKP R9,R22,R56
	JNE R8,R9,str_cmp_exit
	JEQ R8,R0,str_cmp_exit_eq

	ROTI R55,R55,#6
	ROTI R56,R56,#6

	;---third char comparison
	MSKP R8,R22,R55
	MSKP R9,R22,R56
	JNE R8,R9,str_cmp_exit
	JEQ R8,R0,str_cmp_exit_eq

	ROTI R55,R55,#6
	ROTI R56,R56,#6

	;---fourth char comparison
	MSKP R8,R22,R55
	MSKP R9,R22,R56
	JNE R8,R9,str_cmp_exit
	JEQ R8,R0,str_cmp_exit_eq

	ADDI R3,R3,#4	;next word
	ADDI R4,R4,#4	;next word
	JMP str_cmp_main_loop

	str_cmp_exit_eq:
	ANYI R59,R0,#1	;strings are equal

	str_cmp_exit:
	POP.W R26
	POP.W R56
	POP.W R55
	POP.W R22
	POP.W R9
	POP.W R8
	POP.W R4
	POP.W R3
	JR R26

	;---------------------------------------------------


	;------------- Find Numbers of Sectors -----------
	; Input: R5 index of item
	; Output: R35 numbers of sectors
	find_numbers_of_sectors:
	;PROLOGUE
	PUSH.W R3
	PUSH.W R4
	PUSH.W R15
	PUSH.W R16
	PUSH.W R65
	;Insert return value on the stack
	PUSH.W R26

	;Calculate the address of start sector word
	ANYI R15,R0,#68000	;sector 200 base
	ANYI R3,R0,#64		;number of address for any item (17 word * 4)
	ANYI R4,R0,#68		;space occupied by 1 item

	;here I read the word for the initial sector
	MUL R4,R0,R65,R4	; item*68 = item_base
	ADD R15,R4,R15		; item_base + 64 = address of field 'begin sector
	ADD R15,R3,R15		; +68000 add base of sector 200

	JSR read_word_SD

	;extract the number of sectors
	ASHI R16,R16,#12

	;save in R35 (return value)
	ANY R35,R0,R16

	;Prologue
	POP.W R26
	POP.W R65
	POP.W R16
	POP.W R15
	POP.W R4
	POP.W R3
	JR R26



	;------------ /Find Numbers of Sectors/-----------


	;-------------- Find Start Sector ----------------
	; Input: R5 index of item
	; Output: R29 start sector
	find_start_sector:
	;PROLOGUE
	PUSH.W R3
	PUSH.W R4
	PUSH.W R15
	PUSH.W R16
	PUSH.W R65
	;Insert return value on the stack
	PUSH.W R26

	;Calculate the address of start sector word
	ANYI R15,R0,#68000	;sector 200 base
	ANYI R3,R0,#60		;number of address for any item (16 word * 4)
	ANYI R4,R0,#68		;space occupied by 1 item

	;here I read the word for the initial sector
	MUL R4,R0,R65,R4	; item*68 = item_base
	ADD R15,R4,R15		; item_base + 60 = address of field 'begin sector
	ADD R15,R3,R15		; +68000 add base of sector 200

	JSR read_word_SD
	;save in R29 (return value)
	ANY R29,R0,R16

	;Prologue
	POP.W R26
	POP.W R65
	POP.W R16
	POP.W R15
	POP.W R4
	POP.W R3
	JR R26


	;--------------/ Find Start Sector /--------------




	;---------------- INTERRUPT SERVICE ROUTINES --------------------
	int_div_zero:
	LEA R3,str_div_by_zero
	JSR println
	RTI

	
	;--- Int procedure Serial 1 key pressed ---
	int_serial1_rx:
	PUSH R52
	PUSH R54
	PUSH R56
	PUSH R57
	PUSH R58
	PUSH R59
  

	; Read single char from Serial 1
	IN R52,90(R0)


	;actual lenght in R56
	LD.W R56,10004(R0)
	ADDI R57,R56,#10008	;first char is at 10008 - R57 is address of current char

 	; It is ENTER?
	JNEI R52,#13,serial1_store_char
	
	ANYI R51,R0,#1
	ST.W 10000(R0),R51		; Set Flag "line ready"
	ST.T 0(R57),R0			; set the string end
	JMP serial1_exit2


	serial1_store_char:
	;se NON E' INVIO allora stampo il carattere
	OUT 50(R0),R52
	;save the readed char 
	ST.T 0(R57),R52
	;Increase the char count
	ADDI R56,R56,#1
	ST.W 10004(R0),R56	;new lenght in 10004


	; wait for another char on serial 1
	OUT 55(R0),R0
	
	serial1_exit2:
	; restore registers and return
	POP.W R59
	POP.W R58
	POP.W R57
	POP.W R56
	POP.W R54
	POP.W R52
	RTI

	;--- Int procedure Serial 2 key pressed ---
	int_serial2_rx:
	PUSH R52
	PUSH R54
	PUSH R56
	PUSH R57
	PUSH R58
	PUSH R59
  

	; Read single char from Serial 2
	IN R52,91(R0)


	;actual lenght in R56
	LD.W R56,10004(R0)
	ADDI R57,R56,#10008	;first char is at 10008 - R57 is address of current char

 	; It is ENTER?
	JNEI R52,#13,serial2_store_char
	
	ANYI R51,R0,#1
	ST.W 10000(R0),R51		; Set Flag "line ready"
	ST.T 0(R57),R0			; set the string end
	JMP serial2_exit2


	serial2_store_char:
	;se NON E' INVIO allora stampo il carattere
	OUT 60(R0),R52
	;save the readed char 
	ST.T 0(R57),R52
	;Increase the char count
	ADDI R56,R56,#1
	ST.W 10004(R0),R56	;new lenght in 10004


	; wait for another char
	OUT 65(R0),R0
	
	serial2_exit2:
	; restore registers and return
	POP.W R59
	POP.W R58
	POP.W R57
	POP.W R56
	POP.W R54
	POP.W R52
	RTI



	;---------------- INTERRUPT 3 (end of program)
	int_return_to_os:
	POP.W R0 ;clear the stack
	EI
	JMP loop_shell

	;---------------- INTERRUPT 4 (system call for IO.library)
	; R60 = system call ID
	; R61..R65 = parameters
	int_IO_library:
	
	JEQI R60,#1,syscall_print
    JEQI R60,#2,syscall_println
    JMP end_int_4             ; default/error

	syscall_print:
		JSR print
		JMP end_int_4

	syscall_println:
		JSR println

	end_int_4:
		RTI



	;---------------- INTERRUPT GENERIC
	int_generic_handler:
	LEA R3,str_generic_int
	JSR println
	RTI

	;---------------- INTERRUPT UNKNOWN INSTRUCTION
	int_unknown_instruction:
	LEA R3,str_unk_int	
	JSR println
	RTI

	;---------------- INTERRUPT RESERVED INSTRUCTION
	int_reserved_instruction:
	LEA R3,str_reserved_int
	JSR println
	RTI

	;---------------- INTERRUPT RTC
	int_RTC:
	ANYI R44,R0,#'-'
	OUT SERIAL_PORT_2(R0),R44
	RTI

	;---------------- INTERRUPT TIMER 1
	int_Timer_1:
	ANYI R44,R0,#'1'
	OUT SERIAL_PORT_2(R0),R44
	RTI

	;---------------- INTERRUPT TIMER 2
	int_Timer_2:
	ANYI R44,R0,#'2'
	OUT SERIAL_PORT_2(R0),R44
	RTI

	;---------------- INTERRUPT TIMER 3
	int_Timer_3:
	ANYI R44,R0,#'3'
	OUT SERIAL_PORT_2(R0),R44
	RTI
	
    ;---------------- INTERRUPT TIMER 4
	int_Timer_4:
	ANYI R44,R0,#'4'
	OUT SERIAL_PORT_2(R0),R44
	RTI