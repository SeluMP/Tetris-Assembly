# Versión completa del tetris 
# Sincronizada con tetris.s:r3705
# Realizada por José Luis Martínez
        
	.data	

pantalla:
	.word	0
	.word	0
	.space	1024

campo:
	.word	0
	.word	0
	.space	1024
	
	
marcador:
	.word 	0

marcador_anterior:
	.word 	0

pausa:
	.word 	1000

buffer:
	.space 	8
	
pieza_actual:
	.word	0
	.word	0
	.space	1024
	
pieza_siguiente:
	.word 	0
	.word 	0
	.space 	1024

pieza_actual_x:
	.word 0

pieza_actual_y:
	.word 0

imagen_auxiliar:
	.word	0
	.word	0
	.space	1024

pieza_jota:
	.word	2
	.word	3
	.ascii	"\0#\0###\0\0"
	.space	1016

pieza_ele:
	.word	2
	.word	3
	.ascii	"#\0#\0##\0\0"
	.space	1016

pieza_barra:
	.word	1
	.word	4
	.ascii	"####\0\0\0\0"
	.space	1016

pieza_zeta:
	.word	3
	.word	2
	.ascii	"##\0\0##\0\0"
	.space	1016

pieza_ese:
	.word	3
	.word	2
	.ascii	"\0####\0\0\0"
	.space	1016

pieza_cuadro:
	.word	2
	.word	2
	.ascii	"####\0\0\0\0"
	.space	1016

pieza_te:
	.word	3
	.word	2
	.ascii	"\0#\0###\0\0"
	.space	1016

piezas:
	.word	pieza_jota
	.word	pieza_ele
	.word	pieza_zeta
	.word	pieza_ese
	.word	pieza_barra
	.word	pieza_cuadro
	.word	pieza_te

acabar_partida:
	.byte	0
	.align 	2
	
acabar_partida_campo_lleno:
	.byte 	0
	.align	2
	
procesar_entrada.opciones:
	.byte	'x'
	.space	3
	.word	tecla_salir
	.byte	'j'
	.space	3
	.word	tecla_izquierda
	.byte	'l'
	.space	3
	.word	tecla_derecha
	.byte	'k'
	.space	3
	.word	tecla_abajo
	.byte	'i'
	.space	3
	.word	tecla_rotar
	.byte	't'
	.space	3
	.word	tecla_truco

mensaje_campo_lleno:
	.word 	19
	.word 	4
	.ascii 	"+-----------------+"
	.ascii 	"|  FIN DE PARTIDA |"
	.ascii 	"| Pulse una tecla |"
	.ascii 	"+-----------------+"
	.space 	948


menu:
	.asciiz		"##### ##### ##### ####  #####  ####\n  #   #       #   #  ##   #   #    \n  #   #####   #   ###     #    ### \n  #   #       #   #  #    #       #\n  #   #####   #   #   # ##### #### \n\n 1 - Jugar\n 2 - Salir\n 3 - Configuración\n\nElige una opción:\n"
adios:
	.asciiz		"\n¡Adiós!\n"
opcincorrecta:
	.asciiz		"\nOpción incorrecta. Pulse cualquier tecla para seguir.\n"

puntuacion: 
	.asciiz 	"Puntuación: "
bordesupeinfrecuadro:
	.asciiz 	"+---+"
menuconfig: 
	.asciiz		"##### ##### ##### ####  #####  ####\n  #   #       #   #  ##   #   #    \n  #   #####   #   ###     #    ### \n  #   #       #   #  #    #       #\n  #   #####   #   #   # ##### #### \n\n MENÚ DE CONFIGURACIÓN \n\n 1 - Modificar velocidad inicial\n 2 - Salir\n\nElige una opción:\n"
pedirveloc:
	.asciiz		"Introduzca la velocidad inicial deseada: [300-1500]\n"
vactual:
	.asciiz		"\nLa velocidad inicial actualmente es de "
pulsartecla:
	.asciiz		"\nPulse cualquier tecla para seguir."
vincorrecta:
	.asciiz		"\nEl valor de velocidad inicial introducido no está dentro del rango permitido [300-1500]. Pulse cualquier tecla para seguir.\n"	

	.text	

imagen_pixel_addr:			# ($a0, $a1, $a2) = (imagen, x, y)
					# pixel_addr = &data + y*ancho + x
    	lw	$t1, 0($a0)		# $a0 = dirección de la imagen 
					# $t1 ← ancho
    	mul	$t1, $t1, $a2		# $a2 * ancho
    	addu	$t1, $t1, $a1		# $a2 * ancho + $a1
    	addiu	$a0, $a0, 8		# $a0 ← dirección del array data
    	addu	$v0, $a0, $t1		# $v0 = $a0 + $a2 * ancho + $a1
    	jr	$ra


imagen_get_pixel:			# ($a0, $a1, $a2) = (img, x, y)
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)		# guardamos $ra porque haremos un jal
	jal	imagen_pixel_addr	# (img, x, y) ya en ($a0, $a1, $a2)
	lbu	$v0, 0($v0)		# lee el pixel a devolver
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra


imagen_set_pixel:			# ($a0, $a1, $a2, $a3) = (img, x, y, color)
	addiu	$sp, $sp, -8
	sw	$ra, 4($sp)		# guardamos $ra porque haremos un jal
	sw	$s0, 0($sp)		# guardamos $s0 para almacenar color 
	
	move	$s0, $a3		# Pixel color
	
	jal	imagen_pixel_addr	# (img, x, y) ya en ($a0, $a1, $a2)
	sb	$s0, 0($v0)		# *pixel = color
	
	lw	$s0, 0($sp)
	lw	$ra, 4($sp)
	addiu	$sp, $sp, 8
	jr	$ra 


imagen_clean:				# ($a0, $a1) = (img,fondo)
	addiu	$sp, $sp, -28
	sw	$ra, 24($sp)		# guardamos $ra porque haremos un jal
	sw	$s0, 20($sp)		# guardamos $s0 para almacenar img 
	sw	$s1, 16($sp)		# guardamos $s1 para almacenar fondo
	sw	$s2, 12($sp)		
	sw	$s3, 8($sp)		
	sw	$s4, 4($sp)		
	sw	$s5, 0($sp)		

	move	$s0, $a0		# Imagen *img
	move	$s1, $a1		# Pixel fondo
	
	lw	$s2, 4($s0)		# img->alto
	lw	$s3, 0($s0)		# img->ancho
	
	move	$s4, $zero		# y = 0					
	
imagen_clean_for1:	
	bge	$s4, $s2, imagen_clean_fin # (y < img->alto) ?
	
	move	$s5, $zero		# x = 0

imagen_clean_for2:
	bge	$s5, $s3, imagen_clean_finfor1	# (x < img->ancho) ?
	
	move	$a0, $s0		
	move	$a1, $s5		
	move	$a2, $s4		
	move	$a3, $s1		
	jal	imagen_set_pixel

imagen_clean_finfor2:
	addiu	$s5, $s5, 1		# x++
	j	imagen_clean_for2

imagen_clean_finfor1:
	addiu	$s4, $s4, 1		# y++
	j	imagen_clean_for1																					

imagen_clean_fin:
	lw	$s5, 0($sp)
	lw	$s4, 4($sp)
	lw	$s3, 8($sp)
	lw	$s2, 12($sp)
	lw	$s1, 16($sp)
	lw	$s0, 20($sp)
	lw	$ra, 24($sp)
	addiu	$sp, $sp, 28
	jr	$ra
 
               
imagen_init:				# ($a0, $a1, $a2, $a3) = (img, x, y, fondo)
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
		
	sw	$a1, 0($a0)		# img->ancho = ancho
	sw	$a2, 4($a0)		# img->alto = alto
	
	move	$a1, $a3
	jal	imagen_clean
	
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra


imagen_copy:				# ($a0, $a1) = (dst, src)
	addiu	$sp, $sp, -28
	sw	$ra, 24($sp)		# guardamos $ra porque haremos un jal
	sw	$s0, 20($sp)		# guardamos $s0 para almacenar dst 
	sw	$s1, 16($sp)		# guardamos $s1 para almacenar src
	sw	$s2, 12($sp)		
	sw	$s3, 8($sp)		
	sw	$s4, 4($sp)		
	sw	$s5, 0($sp)
	
	move	$s0, $a0		# Imagen *dst
	move	$s1, $a1		# Imagen *src
	
	lw	$s2, 0($s1)		# src->ancho
	lw	$s3, 4($s1)		# src->alto
	
	sw	$s2, 0($s0)		# dst->ancho = src->ancho
	sw	$s3, 4($s0)		# dst->alto = src->alto
	
	move	$s4, $zero		# y = 0

imagen_copy_for1:
	bge	$s4, $s3, imagen_copy_fin # (y < src-> alto) ?
	
	move	$s5, $zero		# x = 0
	
imagen_copy_for2:
	bge	$s5, $s2, imagen_copy_finfor1	# (x < src-> ancho) ?
	
	move	$a0, $s1
	move	$a1, $s5
	move	$a2, $s4
	jal	imagen_get_pixel	# Devuelve pixel p
	
	move	$a0, $s0
	move	$a1, $s5
	move	$a2, $s4
	move	$a3, $v0		# Pixel p	
	jal	imagen_set_pixel

imagen_copy_finfor2:
	addiu	$s5, $s5, 1		# x++
	j	imagen_copy_for2
	
imagen_copy_finfor1:
	addiu	$s4, $s4, 1		# y++
	j	imagen_copy_for1
	
imagen_copy_fin:
	lw	$ra, 24($sp)
	lw	$s0, 20($sp)		
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)
	lw	$s3, 8($sp)
	lw	$s4, 4($sp)
	lw	$s5, 0($sp)
	addiu	$sp, $sp, 28
	jr	$ra
	
																																	
imagen_print:				# $a0 = img
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s0, $a0
	lw	$s3, 4($s0)		# img->alto
	lw	$s4, 0($s0)		# img->ancho
        #  for (int y = 0; y < img->alto; ++y)
	li	$s1, 0			# y = 0
B6_2:	bgeu	$s1, $s3, B6_5		# acaba si y ≥ img->alto
	#    for (int x = 0; x < img->ancho; ++x)
	li	$s2, 0			# x = 0
B6_3:	bgeu	$s2, $s4, B6_4		# acaba si x ≥ img->ancho
	move	$a0, $s0		# Pixel p = imagen_get_pixel(img, x, y)
	move	$a1, $s2
	move	$a2, $s1
	jal	imagen_get_pixel
	move	$a0, $v0		# print_character(p)
	jal	print_character
	addiu	$s2, $s2, 1		# ++x
	j	B6_3
	#    } // for x
B6_4:	li	$a0, 10			# print_character('\n')
	jal	print_character
	addiu	$s1, $s1, 1		# ++y
	j	B6_2
	#  } // for y
B6_5:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$ra, 20($sp)
	addiu	$sp, $sp, 24
	jr	$ra


imagen_dibuja_imagen:			# ($a0, $a1, $a2, $a3) = (dst, src, dst_x, dst_y)
	addiu	$sp, $sp, -36
	sw	$ra, 32($sp)		# guardamos $ra porque haremos un jal
	sw	$s0, 28($sp)		# guardamos $s0 para almacenar dst 
	sw	$s1, 24($sp)		# guardamos $s1 para almacenar src
	sw	$s2, 20($sp)		
	sw	$s3, 16($sp)		
	sw	$s4, 12($sp)		
	sw	$s5, 8($sp)
	sw	$s6, 4($sp)
	sw	$s7, 0($sp)
	
	move	$s0, $a0		# Imagen *dst
	move	$s1, $a1		# Imagen *src
	move	$s2, $a2		# int dst_x
	move	$s3, $a3		# int dst_y
	
	lw	$s4, 0($s1)		# src->ancho
	lw	$s5, 4($s1)		# src->alto	
	
	move	$s6, $zero		# y = 0
	
imagen_dibuja_imagen_for1:
	bge 	$s6, $s5, imagen_dibuja_imagen_fin  # (y < src-> alto) ?
	
	move	$s7, $zero		# x = 0
	
imagen_dibuja_imagen_for2:
	bge	$s7, $s4, imagen_dibuja_imagen_finfor1  # (x < src-> ancho) ?	
	
	move	$a0, $s1
	move	$a1, $s7
	move	$a2, $s6
	jal	imagen_get_pixel	# Devuelve Pixel p
	
imagen_dibuja_imagen_if:
	beqz	$v0, imagen_dibuja_imagen_finfor2	
	
	move	$a0, $s0
	add	$a1, $s2, $s7
	add	$a2, $s3, $s6
	move	$a3, $v0
	jal	imagen_set_pixel
	
imagen_dibuja_imagen_finfor2:
	addiu	$s7, $s7, 1		# x++
	j	imagen_dibuja_imagen_for2
	
imagen_dibuja_imagen_finfor1:
	addiu	$s6, $s6, 1		# y++
	j	imagen_dibuja_imagen_for1
			
imagen_dibuja_imagen_fin:
	lw	$ra, 32($sp)
	lw	$s0, 28($sp)		
	lw	$s1, 24($sp)
	lw	$s2, 20($sp)
	lw	$s3, 16($sp)
	lw	$s4, 12($sp)
	lw	$s5, 8($sp)
	lw	$s6, 4($sp)
	lw	$s7, 0($sp)
	addiu	$sp, $sp, 36
	jr	$ra


imagen_dibuja_imagen_rotada:		# ($a0, $a1, $a2, $a3) = (dst, src, dst_x, dst_y)
	addiu 	$sp, $sp, -36
	sw	$ra, 32($sp)		# guardamos $ra porque haremos un jal
	sw	$s0, 28($sp)		# guardamos $s0 para almacenar dst 
	sw	$s1, 24($sp)		# guardamos $s1 para almacenar src
	sw	$s2, 20($sp)		
	sw	$s3, 16($sp)		
	sw	$s4, 12($sp)		
	sw	$s5, 8($sp)
	sw	$s6, 4($sp)
	sw	$s7, 0($sp)
	
	move	$s0, $a0		# Imagen *dst
	move	$s1, $a1		# Imagen *src
	move	$s2, $a2		# int dst_x
	move	$s3, $a3		# int dst_y
	
	lw	$s4, 0($s1)		# src->ancho
	lw	$s5, 4($s1)		# src->alto	
	
	move	$s6, $zero		# y = 0
	
imagen_dibuja_imagen_rot_for1:
	bge 	$s6, $s5, imagen_dibuja_imagen_rot_fin  # (y < src-> alto) ?
	
	move	$s7, $zero		# x = 0
	
imagen_dibuja_imagen_rot_for2:
	bge	$s7, $s4, imagen_dibuja_imagen_rot_finfor1  # (x < src-> ancho) ?	
	
	move	$a0, $s1
	move	$a1, $s7
	move	$a2, $s6
	jal	imagen_get_pixel	# Devuelve Pixel p
	
imagen_dibuja_imagen_rot_if:
	beqz	$v0, imagen_dibuja_imagen_rot_finfor2	
	
	add	$t0, $s2, $s5		# $t0 = dst_x + src->alto
	subi	$t0, $t0, 1		# $t0 = $t0 - 1
	sub	$t0, $t0, $s6 		# $t0 = $t0 - y
	
	move	$a0, $s0
	move	$a1, $t0
	add	$a2, $s3, $s7
	move	$a3, $v0
	jal	imagen_set_pixel
	
imagen_dibuja_imagen_rot_finfor2:
	addiu	$s7, $s7, 1		# x++
	j	imagen_dibuja_imagen_rot_for2
	
imagen_dibuja_imagen_rot_finfor1:
	addiu	$s6, $s6, 1		# y++
	j	imagen_dibuja_imagen_rot_for1
			
imagen_dibuja_imagen_rot_fin:
	lw	$ra, 32($sp)
	lw	$s0, 28($sp)		
	lw	$s1, 24($sp)
	lw	$s2, 20($sp)
	lw	$s3, 16($sp)
	lw	$s4, 12($sp)
	lw	$s5, 8($sp)
	lw	$s6, 4($sp)
	lw	$s7, 0($sp)
	addiu	$sp, $sp, 36
	jr	$ra


integer_to_string:
        move    $t0, $a1
       	beqz	$a0, B9_6
        abs     $t1, $a0
        li      $t3, 10
B9_3:   blez	$t1, B9_4
	div	$t1, $t3
	mflo	$t1	
	mfhi	$t2	
	addiu	$t2, $t2, '0'
        sb	$t2, 0($t0)
	addiu	$t0, $t0, 1
	j	B9_3
B9_4:	bgez	$a0, B9_7
	li	$t2, '-'
	sb	$t2, 0($t0)
	addiu	$t0, $t0, 1
	j	B9_7
B9_6:	li	$t2, '0'
	sb	$t2, 0($t0)
	addiu	$t0, $t0, 1
B9_7:	sb	$zero, 0($t0)
	addiu	$t0, $t0, -1
B9_9:   ble     $t0, $a1, B9_10
        lbu	$t2, 0($a1)
	lbu	$t3, 0($t0)
	sb	$t3, 0($a1)
	sb	$t2, 0($t0)
	addiu	$t0, $t0, -1
	addiu	$a1, $a1, 1
	j       B9_9
B9_10:	jr	$ra


imagen_dibuja_cadena: 	# $a0 = &img, $a1= pos_x, $a2 = pos_y, $a3 = &cad
	addi 	$sp, $sp -20
	sw 	$ra, 0($sp)
	sw 	$s0, 4($sp)
	sw 	$s1, 8($sp)
	sw 	$s2, 12($sp) 
	sw 	$s3, 16($sp)
	move 	$s0, $a0		# $s0 = &img
	move 	$s1, $a1		# $s1 = pos_x
	move 	$s2, $a2		# $s2 = pos_y
	move 	$s3, $a3		# $s3 = &cad
	
imagen_dibuja_cadena_for:
	lb 	$t0, 0($s3)		# $t0 = cad[0]
	beqz 	$t0, imagen_dibuja_cadena_fin	# Salta si $t0 == 0
	move 	$a0, $s0		# $a0 = &img
	move 	$a1, $s1		# $a1 = pos_x
	move 	$a2, $s2		# $a2 = pos_y
	move 	$a3, $t0		# $a3 = cad[0]
	jal 	imagen_set_pixel	# imagen_set_pixel()
	addi 	$s3, $s3, 1		# cad[+1]
	addi 	$s1, $s1, 1		# pos_x++
	j 	imagen_dibuja_cadena_for	
	
imagen_dibuja_cadena_fin:	
	lw 	$ra, 0($sp)
	lw 	$s0, 4($sp)
	lw 	$s1, 8($sp)
	lw 	$s2, 12($sp) 
	lw 	$s3, 16($sp)
	addi 	$sp, $sp, 20
	jr 	$ra


mostrar_puntuacion:
	addi 	$sp, $sp, -8
	sw 	$ra, 0($sp)
	sw 	$s0, 4($sp)
	la 	$s0, buffer		# $s0 = &buffer
	la 	$a0, pantalla		# $a0 = &pantalla
	li 	$a1, 0			# $a1 = 0
	li 	$a2, 0			# $a2 = 0
	la 	$a3, puntuacion		# $a3 -> "Puntuacion: "
	jal 	imagen_dibuja_cadena 
	lw 	$a0, marcador		# $a0 = marcador
	move 	$a1, $s0		# $a1 = buffer
	jal 	integer_to_string
	la 	$a0, pantalla 		# $a0 = &pantalla
	li 	$a1, 12			# $a1 = 12
	li 	$a2, 0			# $a2 = 0
	la	$a3, buffer		# $a3 = &buffer
	jal 	imagen_dibuja_cadena
	lw 	$ra, 0($sp)
	lw 	$s0, 4($sp)
	addi 	$sp, $sp, 8
	jr 	$ra
	

pieza_aleatoria:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	li	$a0, 0
	li	$a1, 7
	jal	random_int_range	# $v0 ← random_int_range(0, 7)
	sll	$t1, $v0, 2
	la	$v0, piezas
	addu	$t1, $v0, $t1		# $t1 = piezas + $v0*4
	lw	$v0, 0($t1)		# $v0 ← piezas[$v0]
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

actualizar_pantalla:
	addiu	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s2, 4($sp)
	sw	$s1, 0($sp)
	la	$s2, campo
	la	$a0, pantalla
	li	$a1, ' '
	jal	imagen_clean		# imagen_clean(pantalla, ' ')
        # for (int y = 0; y < campo->alto; ++y) {
	li	$s1, 0			# y = 0
B10_2:	lw	$t1, 4($s2)		# campo->alto
	bge	$s1, $t1, B10_3		# sigue si y < campo->alto
	la	$a0, pantalla
	li	$a1, 0                  # pos_campo_x - 1
	addi	$a2, $s1, 2             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, 0, y, '|')
	la	$a0, pantalla
	lw	$t1, 0($s2)		# campo->ancho
	addiu	$a1, $t1, 1		# campo->ancho + 1
	addiu	$a2, $s1, 2             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, campo->ancho + 1, y, '|')
        addiu	$s1, $s1, 1		# ++y
        j       B10_2
        # } // for y
	# for (int x = 0; x < campo->ancho + 2; ++x) { 
B10_3:	li	$s1, 0			# x = 0
B10_5:  lw	$t1, 0($s2)		# campo->ancho
        addiu   $t1, $t1, 2             # campo->ancho + 2
        bge	$s1, $t1, B10_6		# sigue si x < campo->ancho + 2
	la	$a0, pantalla
	move	$a1, $s1                # pos_campo_x - 1 + x
        lw	$t1, 4($s2)		# campo->alto
	addiu	$a2, $t1, 2		# campo->alto + pos_campo_y
	li	$a3, '-'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, x, campo->alto + 1, '-')
	addiu	$s1, $s1, 1		# ++x
	j       B10_5
        # } // for x
B10_6:	
	la	$a0, pantalla
	jal 	mostrar_puntuacion
	la	$a0, pantalla
	move	$a1, $s2
	li	$a2, 1                  # pos_campo_x
	li	$a3, 2                  # pos_campo_y
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, campo, 1, 2)
	la	$a0, pantalla
	la	$a1, pieza_actual
	lw	$t1, pieza_actual_x
	addiu	$a2, $t1, 1		# pieza_actual_x + pos_campo_x
	lw	$t1, pieza_actual_y
	addiu	$a3, $t1, 2		# pieza_actual_y + pos_campo_y
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, pieza_actual, pieza_actual_x + pos_campo_x, pieza_actual_y + pos_campo_y)
	
	la 	$a0, pantalla
	li 	$a1, 21
	li 	$a2, 2
	la 	$a3, bordesupeinfrecuadro
	jal	imagen_dibuja_cadena 	# imagen_dibuja_cadena "+---+" superior
	
	la 	$a0, pantalla
	la 	$a1, pieza_siguiente
	li 	$a2, 22
	li 	$a3, 3
	jal 	imagen_dibuja_imagen 	# imagen_dibuja_imagen (pieza_siguiente)
	
	la 	$a0, pantalla
	li 	$a1, 21
	li 	$a2, 7
	la 	$a3, bordesupeinfrecuadro
	jal	imagen_dibuja_cadena 	# imagen_dibuja_cadena "+---+" inferior
	
	li	$s1, 0		# y = 0
actualizar_pantalla_bordes:
	li 	$t1, 4
	bge	$s1, $t1, actualizar_pantalla_bordes_fin # sigue si y < campo->alto
	la	$a0, pantalla
	li	$a1, 21                 # pos_campo_x - 1
	addi	$a2, $s1, 3             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, 0, y, '|')
	la	$a0, pantalla
	li	$a1, 25                  # pos_campo_x - 1
	addi	$a2, $s1, 3             # y + pos_campo_
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, campo->ancho + 1, y, '|')
        addiu	$s1, $s1, 1		# ++y
        j       actualizar_pantalla_bordes
	
actualizar_pantalla_bordes_fin:	
	jal	clear_screen		# clear_screen()
	la	$a0, pantalla
	jal	imagen_print		# imagen_print(pantalla)
	lw	$s1, 0($sp)
	lw	$s2, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

nueva_pieza_actual:			# (void)
	addiu 	$sp, $sp, -8
	sw 	$ra, 0($sp)
	sw 	$s0, 4($sp)
	la 	$a0, pieza_actual
	la 	$a1, pieza_siguiente
	jal 	imagen_copy
	jal 	pieza_aleatoria		# llamada a la función pieza_actual()
	move 	$s0, $v0		# $s0 = pieza_aleatoria
	move 	$a0, $s0
	li 	$a1, 8
	li 	$a2, 0
	jal 	probar_pieza
	beqz 	$v0, nueva_pieza_actual_else
	la 	$a0, pieza_siguiente	# $a0 = pieza_actual
	move 	$a1, $s0 		# $a1 = elegida ($v0, valor devuelto por pieza aleatoria)
	jal 	imagen_copy		# imagen_copy (pieza_actual, elegida)
	li 	$t0, 8
	li 	$t1, 0
	sw 	$t0, pieza_actual_x	# pieza_actual_x = 8
	sw 	$t1, pieza_actual_y	# pieza_actual_y = 0
	j 	nueva_pieza_fin
nueva_pieza_actual_else:
	li 	$t2, 1
	sb 	$t2, acabar_partida
	sb 	$t2, acabar_partida_campo_lleno
nueva_pieza_fin:
	lw 	$ra, 0($sp)
	lw 	$s0, 4($sp)
	addiu 	$sp, $sp, 8
	jr 	$ra

probar_pieza:				# ($a0, $a1, $a2) = (pieza, x, y)
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s7, 24($sp)
	sw	$s6, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s0, $a2		# y
	move	$s1, $a1		# x
	move	$s2, $a0		# pieza
	li	$v0, 0
	bltz	$s1, B12_13		# if (x < 0) return false
	lw	$t1, 0($s2)		# pieza->ancho
	addu	$t1, $s1, $t1		# x + pieza->ancho
	la	$s4, campo
	lw	$v1, 0($s4)		# campo->ancho
	bltu	$v1, $t1, B12_13	# if (x + pieza->ancho > campo->ancho) return false
	bltz	$s0, B12_13		# if (y < 0) return false
	lw	$t1, 4($s2)		# pieza->alto
	addu	$t1, $s0, $t1		# y + pieza->alto
	lw	$v1, 4($s4)		# campo->alto
	bltu	$v1, $t1, B12_13	# if (campo->alto < y + pieza->alto) return false
	# for (int i = 0; i < pieza->ancho; ++i) {
	lw	$t1, 0($s2)		# pieza->ancho
	beqz	$t1, B12_12
	li	$s3, 0			# i = 0
	#   for (int j = 0; j < pieza->alto; ++j) {
	lw	$s7, 4($s2)		# pieza->alto
B12_6:	beqz	$s7, B12_11
	li	$s6, 0			# j = 0
B12_8:	move	$a0, $s2
	move	$a1, $s3
	move	$a2, $s6
	jal	imagen_get_pixel	# imagen_get_pixel(pieza, i, j)
	beqz	$v0, B12_10		# if (imagen_get_pixel(pieza, i, j) == PIXEL_VACIO) sigue
	move	$a0, $s4
	addu	$a1, $s1, $s3		# x + i
	addu	$a2, $s0, $s6		# y + j
	jal	imagen_get_pixel
	move	$t1, $v0		# imagen_get_pixel(campo, x + i, y + j)
	li	$v0, 0
	bnez	$t1, B12_13		# if (imagen_get_pixel(campo, x + i, y + j) != PIXEL_VACIO) return false
B12_10:	addiu	$s6, $s6, 1		# ++j
	bltu	$s6, $s7, B12_8		# sigue si j < pieza->alto
        #   } // for j
B12_11:	lw	$t1, 0($s2)		# pieza->ancho
	addiu	$s3, $s3, 1		# ++i
	bltu	$s3, $t1, B12_6 	# sigue si i < pieza->ancho
        # } // for i
B12_12:	li	$v0, 1			# return true
B12_13:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s6, 20($sp)
	lw	$s7, 24($sp)
	lw	$ra, 28($sp)
	addiu	$sp, $sp, 32
	jr	$ra

intentar_movimiento: 	# $a0 = x, $a1 = y
	addiu 	$sp, $sp, -12
	sw 	$ra, 8($sp)
	sw 	$s1, 4($sp)
	sw 	$s0, 0($sp)
	move 	$s0, $a0		# preservamos el valor de x
	move 	$s1, $a1		# preservamos el valor de y
	la 	$a0, pieza_actual	# $a0 = pieza_actual
	move 	$a1, $s0		# $a1 = x
	move 	$a2, $s1		# $a2 = y
	jal 	probar_pieza		# probar_pieza(pieza_actual,x,y)
im_if_true:
	beqz 	$v0, im_fin
	sw 	$s0, pieza_actual_x	# pieza_actual_x = x;
	sw 	$s1, pieza_actual_y	# pieza_actual_y = y;
	li 	$v0, 1			# $v0 = true
	j 	im_fin
im_fin:
	lw 	$s0, 0($sp)
	lw 	$s1, 4($sp)
	lw 	$ra, 8($sp)
	addiu 	$sp, $sp, 12
	jr 	$ra

bajar_pieza_actual:
	addiu 	$sp, $sp, -28
	sw 	$ra, 24($sp)
	sw 	$s5, 20($sp)		# pieza_actual.alto
	sw 	$s4, 16($sp)		# y
	sw 	$s3, 12($sp)		# campo
	sw 	$s2, 8($sp)		# pieza_actual_y
	sw 	$s1, 4($sp)		# pieza_actual_x
	sw 	$s0, 0($sp)		# pieza_actual
	la 	$s0, pieza_actual	# preservamos el valor de pieza_actual
	lw	$s1, pieza_actual_x	# preservamos el valor de pieza_actual_x
	lw 	$s2, pieza_actual_y	# preservamos el valor de pieza_actual_y
	la 	$s3, campo
	move 	$a0, $s1		# $a1 = pieza_actual_x
	addi 	$a1, $s2, 1		# $a1 = pieza_actual_y + 1
	jal 	intentar_movimiento	# intentar_movimiento(pieza_actual_x, pieza_actual_y + 1)
	bnez 	$v0, bajar_pieza_actual_fin # if (!intentar_movimiento(pieza_actual_x, pieza_actual_y + 1))
     	move	$a0, $s3		# $a0 = campo
     	move 	$a1, $s0		# $a1 = pieza_actual
     	move 	$a2, $s1		# $a2 = pieza_actual_x
     	move 	$a3, $s2		# $a3 = pieza_actual_y
     	jal 	imagen_dibuja_imagen	# imagen_dibuja_imagen(campo, pieza_actual, pieza_actual_x, pieza_actual_y)
     	li 	$s4, 0			# y = 0
     	lw 	$s5, 4($s0)    		# $s5 = pieza_actua.alto
bajar_pieza_actual_for:
	bge 	$s4, $s5, bajar_pieza_actual_for_fin # for(int y = 0; y < pieza_actual.alto, y++)
     	add	$a0, $s2, $s4		# pieza_actual_y + y
     	jal 	linea_completa
     	beqz	$v0, bajar_pieza_actual_for_cont # if(linea_completa(pieza_actual_y + y)
     	lw 	$t0, marcador		# $t0 = marcador
     	addi 	$t0, $t0, 10		# marcador += 10
     	sw 	$t0, marcador		# MEM[marcador]
     	add	$a0, $s2, $s4		# pieza_actual_y + y
     	jal 	linea_eliminar		# linea_eliminar(pieza_actual_y + y)
bajar_pieza_actual_for_cont:    	 	
     	addi 	$s4, $s4, 1		# y++
     	j 	bajar_pieza_actual_for
bajar_pieza_actual_for_fin:     	     	
     	jal 	nueva_pieza_actual	# nueva_pieza_actual()
     	lw 	$t0, marcador		# $t0 = marcador
     	addi 	$t0, $t0, 1		# marcador++
     	sw 	$t0, marcador		# MEM[marcador]
bajar_pieza_actual_fin:
	lw 	$s0, 0($sp)
	lw 	$s1, 4($sp)
	lw  	$s2, 8($sp)
	lw 	$s3, 12($sp)
	lw 	$s4, 16($sp)
	lw 	$s5, 20($sp)
	lw 	$ra, 24($sp)
	addiu 	$sp, $sp, 28
	jr 	$ra

intentar_rotar_pieza_actual:
	addi 	$sp, $sp, -8	
	sw 	$ra, 0($sp)
	sw 	$s0, 4($sp)
	la 	$s0, imagen_auxiliar	# Guardamos el valor de imagen_auxiliar 
	la 	$t1, pieza_actual	# Guardamos el valor de pieza_actual
	move 	$a0, $s0		# $a0 = imagen_auxiliar
	lw 	$a1, 4($t1)		# $a1 = pieza_actual_alto
	lw 	$a2, 0($t1)		# $a2 = pieza_actual_ancho
	move 	$a3, $zero		# $a3 = PIXEL_VACIO
	jal 	imagen_init		# imagen_init(pieza_actual,pieza_actual_alto, pieza_actual_ancho, PIXEL_VACIO)
	move 	$a0, $s0		# $a0 = imagen_auxiliar(pieza_actual)
	la 	$a1, pieza_actual	# $a1 = pieza_actual
	move 	$a2, $zero		# $a2 = 0
	move 	$a3, $zero		# $a3 = 0
	jal 	imagen_dibuja_imagen_rotada	# imagen_dibuja_imagen_rotada(pieza_rotada, pieza_actual, 0, 0)
	la 	$a0, pieza_actual	# $a0 = pieza_actual (pieza_rotada)
	lw 	$a1, pieza_actual_x	# $a1 = pieza_actual_x
	lw 	$a2, pieza_actual_y	# $a2 = pieza_actual_y
	jal 	probar_pieza		# probar_pieza(pieza_rotada, pieza_actual_x, pieza_actual_y)
intentar_rotar_pieza_actual_if:
	beqz 	$v0, intentar_rotar_pieza_actual_fin
	la	$a0, pieza_actual	# $a0 = pieza_actual
	move 	$a1, $s0		# $a1 = pieza_rotada
	jal 	imagen_copy		# imagen_copy(pieza_actual, pieza_rotada)
intentar_rotar_pieza_actual_fin:
	lw 	$s0, 4($sp)
	lw 	$ra, 0($sp)
	addiu 	$sp, $sp, 8
	jr 	$ra 
	
linea_completa:
	addiu 	$sp, $sp, -16
	sw  	$ra, 0($sp)
	sw 	$s0, 4($sp)
	sw 	$s1, 8($sp)
	sw 	$s2, 12($sp)
	li 	$s0, 0			# x = 0
	la 	$t0, campo		# $t0 = $campo
	lw 	$s2, 0($t0)		# $s2 = campo[0]
	move 	$s1, $a0		# $s1 = y
linea_completa_for:
	bge 	$s0, $s2, linea_completa_for_fin # for(int x = 0; x < campo.ancho; x++)
	la 	$a0, campo		# $a0 = &campo
	move 	$a1, $s0		# $a1 = x
	move 	$a2, $s1		# $a2 = y 
	jal 	imagen_get_pixel
	beqz 	$v0, linea_completa_if_fin	# if(imagen_get_pixel(&campo, x ,y) == PIXEL_VACIO)
	addi 	$s0, $s0, 1		# x++
	j 	linea_completa_for
linea_completa_if_fin:
	li 	$v0, 0			# return false
	j	linea_completa_fin	
linea_completa_for_fin:
	li 	$v0, 1			# return true
linea_completa_fin:
	lw  	$ra, 0($sp)
	lw 	$s0, 4($sp)
	lw 	$s1, 8($sp)
	lw 	$s2, 12($sp)
	addiu 	$sp, $sp, 16
	jr 	$ra

linea_eliminar:
	addi 	$sp, $sp, -16
	sw  	$ra, 0($sp)
	sw 	$s0, 4($sp)
	sw 	$s1, 8($sp)
	sw 	$s2, 12($sp)
	move 	$s0, $a0		# $s0 = y
linea_eliminar_for:
	ble 	$s0, $zero, linea_eliminar_for_fin_ini	# for(; y > 0; y--)
	li	$s1, 0			# x = 0
	la 	$t0, campo		# $t0 = &campo
	lw 	$s2, 0($t0)		# $s2 = campo[0]
linea_eliminar_for_2:
	bge 	$s1, $s2, linea_eliminar_for2_fin # for(int x = 0; x < campo.ancho; x++)
	la	$a0, campo		# $a0 = &campo
	move 	$a1, $s1		# $a1 = x
	sub 	$a2, $s0, 1		# $a2 = y -1
	jal 	imagen_get_pixel
	la	$a0, campo		# $a0 = &campo
	move 	$a1, $s1		# $a1 = x
	move 	$a2, $s0		# $a2 = y
	move 	$a3, $v0		# $a2 = p
	jal 	imagen_set_pixel
	addi 	$s1, $s1, 1		# x++
	j 	linea_eliminar_for_2
linea_eliminar_for2_fin:
	addi 	$s0, $s0, -1		# y--
	j 	linea_eliminar_for
linea_eliminar_for_fin_ini:
	li	$s1, 0			# x = 0
linea_eliminar_for_fin:
	bge 	$s1, $s2, linea_eliminar_fin # for(int x = 0; x < campo.ancho; x++)	
	la 	$a0, campo		# $a0 = &campo
	move 	$a1, $s1		# $a1 = x
	move 	$a2, $zero		# $a2 = 0
	move 	$a3, $zero		# $a3 = 0
	jal 	imagen_set_pixel
	addi 	$s1, $s1, 1		# x++
	j 	linea_eliminar_for_fin
linea_eliminar_fin:	
	lw  	$ra, 0($sp)
	lw 	$s0, 4($sp)
	lw 	$s1, 8($sp)
	lw 	$s2, 12($sp)
	addi 	$sp, $sp, 16	
	jr 	$ra

ritmo_caida:
	addi 	$sp, $sp, -4
	sw 	$ra, 0($sp)
	lw 	$t1, marcador		# $t1 = marcador
	lw 	$t2, marcador_anterior	# $t2 = marcador_anterior
	lw 	$t3, pausa		# $t3 = pausa
ritmo_caida_if_menor_300:
	beq 	$t3, 300, ritmo_caida_fin	# if(pausa != 300)
ritmo_caida_if_20:
	sub 	$t4, $t1, $t2		# $t4 = marcador - marcador_anterior
	blt 	$t4, 20, ritmo_caida_if_20_fin # if($t4 < 20)
	mul	$t3, $t3, 9		# pausa*0.9
	div 	$t3, $t3, 10		# pausa/10
	addi 	$t2, $t2, 20		# marcador_anterior + 20
	j 	ritmo_caida_if_20
ritmo_caida_if_20_fin:
	bge 	$t3, 300, ritmo_caida_fin	# if(pausa <= 300)
	li 	$t3, 300		# pausa = 300
ritmo_caida_fin:
	sw 	$t2, marcador_anterior
	sw 	$t3, pausa
	lw 	$ra, 0($sp)
	addi 	$sp, $sp, 4
	jr 	$ra	
																																																																	
tecla_salir:
	li	$v0, 1
	sb	$v0, acabar_partida	# acabar_partida = true
	jr	$ra

tecla_izquierda:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, -1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x - 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_derecha:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, 1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x + 1, pieza_actual_y)
	
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_abajo:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	bajar_pieza_actual	# bajar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_rotar:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	intentar_rotar_pieza_actual	# intentar_rotar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_truco:
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s4, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
       	li	$s4, 18
	#  for (int y = 13; y < 18; ++y) {         
	li	$s0, 13
	#  for (int x = 0; x < campo->ancho - 1; ++x) {
B21_1:	li	$s1, 0
B21_2:	lw	$t1, campo
	addiu	$t1, $t1, -1
	bge	$s1, $t1, B21_3
	la	$a0, campo
	move	$a1, $s1
	move	$a2, $s0
	li	$a3, '#'
	jal	imagen_set_pixel	# imagen_set_pixel(campo, x, y, '#'); 
	addiu	$s1, $s1, 1		# 245   for (int x = 0; x < campo->ancho - 1; ++x) { 
	j	B21_2
B21_3:	addiu	$s0, $s0, 1
	bne	$s0, $s4, B21_1
	la	$a0, campo
	li	$a1, 10
	li	$a2, 16
	li	$a3, 0
	jal	imagen_set_pixel	# imagen_set_pixel(campo, 10, 16, PIXEL_VACIO); 
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s4, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra

procesar_entrada:
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s4, 12($sp)
	sw	$s3, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	jal	keyio_poll_key
	move	$s0, $v0		# int c = keyio_poll_key()
        # for (int i = 0; i < sizeof(opciones) / sizeof(opciones[0]); ++i) { 
	li	$s1, 0			# i = 0, $s1 = i * sizeof(opciones[0]) // = i * 8
	la	$s3, procesar_entrada.opciones	
	li	$s4, 48			# sizeof(opciones) // == 5 * sizeof(opciones[0]) == 5 * 8
B22_1:	addu	$t1, $s3, $s1		# procesar_entrada.opciones + i*8
	lb	$t2, 0($t1)		# opciones[i].tecla
	bne	$t2, $s0, B22_3		# if (opciones[i].tecla != c) siguiente iteración
	lw	$t2, 4($t1)		# opciones[i].accion
	jalr	$t2			# opciones[i].accion()
	jal	actualizar_pantalla	# actualizar_pantalla()
B22_3:	addiu	$s1, $s1, 8		# ++i, $s1 += 8
	bne	$s1, $s4, B22_1		# sigue si i*8 < sizeof(opciones)
        # } // for i
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s3, 8($sp)
	lw	$s4, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra

jugar_partida:
	addiu	$sp, $sp, -12	
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)

	lw 	$t0, marcador
	li 	$t0, 0
	sw 	$t0, marcador
	la	$a0, pantalla
	li	$a1, 26
	li	$a2, 22
	li	$a3, 32
	jal	imagen_init		# imagen_init(pantalla, 20, 22, ' ')
	la	$a0, campo
	la	$a1, 14
	la	$a2, 18
	li	$a3, 0
	jal	imagen_init		# imagen_init(campo, 14, 18, PIXEL_VACIO)
	jal	pieza_aleatoria		# pieza_aleatoria()
	la	$a0, pieza_siguiente	# $a0 = &pieza_siguiente
	move 	$a1, $v0		# $a1 = pieza_aleatoria()
	jal 	imagen_copy		# imagen_copy(&pieza_siguiente, pieza_aleatoria())
	jal	nueva_pieza_actual	# nueva_pieza_actual()
	sb	$zero, acabar_partida	# acabar_partida = false
	jal	get_time		# get_time()
	move	$s0, $v0		# Hora antes = get_time()
	jal	actualizar_pantalla	# actualizar_pantalla()
	j	B23_2
        # while (!acabar_partida) { 
B23_2:	lbu	$t1, acabar_partida
	bnez	$t1, B23_5		# if (acabar_partida != 0) sale del bucle
	jal	procesar_entrada	# procesar_entrada()
	jal	get_time		# get_time()
	move	$s1, $v0		# Hora ahora = get_time()
	subu	$t1, $s1, $s0		# int transcurrido = ahora - antes
	lw 	$t2, pausa
	ble	$t1, $t2, B23_2	# if (transcurrido < pausa) siguiente iteración
	jal 	ritmo_caida
B23_1:	jal	bajar_pieza_actual	# bajar_pieza_actual()
	jal	actualizar_pantalla	# actualizar_pantalla()
	move	$s0, $s1		# antes = ahora
        j	B23_2			# siguiente iteración
       	# } 
B23_5:	
	lb 	$t0, acabar_partida_campo_lleno	# $t0 = acabar_partida_campo_lleno
	beqz 	$t0, jugar_partida_fin	# if(jugar_partida_fin)
	la 	$a0, pantalla		# $a0 = $pantalla
	la 	$a1, mensaje_campo_lleno	# $a1 = &mensaje_campo_lleno
	li 	$a2, 0			# $a2 = 0
	li 	$a3, 8			# $a3 = 8
	jal 	imagen_dibuja_imagen
	jal 	clear_screen
	la 	$a0, pantalla		# $a0 = $pantalla
	jal 	imagen_print
	jal 	read_character
jugar_partida_fin:	
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

	.globl	main
main:					# ($a0, $a1) = (argc, argv) 
	addiu	$sp, $sp, -8
	sw	$ra, 4($sp)
	sw	$s0, 0($sp)
B24_2:	jal	clear_screen		# clear_screen()
	la	$a0, menu
	jal	print_string		# print_string(""##### ##### ##### ####  #####  ####\n  #   #       #   #  ##   #   #    \n  #   #####   #   ###     #    ### \n  #   #       #   #  #    #       #\n  #   #####   #   #   # ##### #### \n\n\n\n 1 - Jugar\n 2 - Salir\n 3 - Configuración\n\nElige una opción:\n")
	jal	read_character		# char opc = read_character()
	beq	$v0, '2', B24_1		# if (opc == '2') salir
	bne	$v0, '1', B24_6		# if (opc != '1') comprobar si es 3 
	jal	jugar_partida		# jugar_partida()
	j	B24_2
B24_1:	la	$a0, adios
	jal	print_string		# print_string("\n¡Adiós!\n")
	li	$a0, 0
	jal	mips_exit		# mips_exit(0)
	j	B24_2
B24_5:	la	$a0, opcincorrecta
	jal	print_string		# print_string("\nOpción incorrecta. Pulse cualquier tecla para seguir.\n")
	jal	read_character		# read_character()
	j	B24_2
	lw	$ra, 4($sp)
	lw	$s0, 0($sp)
	addiu	$sp, $sp, 8
	jr	$ra
B24_6:
	bne	$v0, '3', B24_5	       # if (opc != '3') mostrar error
	jal	mostrar_configuracion_inicio
	j 	B24_2
	
mostrar_configuracion_inicio:
	jal	clear_screen
	
	la	$a0, menuconfig
	jal	print_string		# print_string("##### ##### ##### ####  #####  ####\n  #   #       #   #  ##   #   #    \n  #   #####   #   ###     #    ### \n  #   #       #   #  #    #       #\n  #   #####   #   #   # ##### #### \n\n MENÚ DE CONFIGURACIÓN \n\n 1 - Modificar velocidad inicial\n 2  - Salir\n\nElige una opción:\n")
	
	jal	read_character		# char opc = read_character()
	beq	$v0, '2',  mostrar_configuracion_salir 				# if (opc == '2') salir
	bne	$v0, '1',  mostrar_configuracion_opcion_incorrecta		# if (opc != '1') cerror
	
mostrar_configuracion_cambiar_velocidad_ini:
	jal	clear_screen
	la	$a0, pedirveloc
	jal	print_string		# print_string("\nIntroduzca la velocidad inicial deseada [300-1500]:\n")
	jal	read_integer		# char opc = read_character()
	move	$s0, $v0
	
mostrar_configuracion_comprobar_vi:
	blt	$s0, 300, velocidad_no_permitida
	bgt	$s0, 1500, velocidad_no_permitida
	lw	$t0, pausa
	move	$t0, $s0
	sw	$t0, pausa
	
	la	$a0, vactual
	jal	print_string		# print_string("\nLa velocidad inicial actualmente es de ")
	move	$a0, $s0	  	  
	jal	print_integer
	la	$a0, pulsartecla
	jal	print_string		# print_string("\nPulse cualquier tecla para seguir.\n")
	jal	read_character		# read_character()
	j	mostrar_configuracion_inicio

velocidad_no_permitida:
	la	$a0, vincorrecta
	jal	print_string		# print_string("\nEl valor de velocidad inicial introducido no está dentro del rango permitido. Pulse cualquier tecla para seguir.\n")
	jal	read_character		# read_character()
	j	mostrar_configuracion_cambiar_velocidad_ini
			
mostrar_configuracion_salir:
	j 	B24_2
			
mostrar_configuracion_opcion_incorrecta:
	la	$a0, opcincorrecta
	jal	print_string		# print_string("\nOpción incorrecta. Pulse cualquier tecla para seguir.\n")
	jal	read_character		# read_character()
	j	mostrar_configuracion_inicio
	

#
# Funciones de la librería del sistema
#

print_character:
	li	$v0, 11
	syscall	
	jr	$ra

print_string:
	li	$v0, 4
	syscall	
	jr	$ra

get_time:
	li	$v0, 30
	syscall	
	move	$v0, $a0
	move	$v1, $a1
	jr	$ra

read_character:
	li	$v0, 12
	syscall	
	jr	$ra
	
print_integer:
	li	$v0, 1
	syscall	
	jr	$ra
	
read_integer:
	li	$v0, 5
	syscall	
	jr	$ra

clear_screen:
	li	$v0, 39
	syscall	
	jr	$ra

mips_exit:
	li	$v0, 17
	syscall	
	jr	$ra

random_int_range:
	li	$v0, 42
	syscall	
	move	$v0, $a0
	jr	$ra

keyio_poll_key:
	li	$v0, 0
	lb	$t0, 0xffff0000
	andi	$t0, $t0, 1
	beqz	$t0, keyio_poll_key_return
	lb	$v0, 0xffff0004
	
keyio_poll_key_return:
	jr	$ra
