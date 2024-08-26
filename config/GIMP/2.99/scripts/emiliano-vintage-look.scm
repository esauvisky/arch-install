(define (emiliano-vintage-look image)
	(let* 	(
				(drawable 	(car (gimp-image-get-active-drawable image)))
				(width 		(car (gimp-image-width image)))
				(height 	(car (gimp-image-height image)))
				(layer		())
			)

		; converte para RGB
		(if (= (car (gimp-drawable-is-rgb drawable)) FALSE) (gimp-image-convert-rgb image) )

		; adiciona camada amarelo
		(set! layer (car (gimp-layer-new image
						width
						height
						RGB-IMAGE
						"Yellow"
						59
						MULTIPLY-MODE)))
    	(gimp-image-insert-layer image layer 0 0)
    	; preenche camada
		(gimp-context-set-foreground '(251 242 163))
		(gimp-edit-fill layer 0)

  		; adiciona camada magenta
		(set! layer (car (gimp-layer-new image
						width
						height
						RGB-IMAGE
						"Magenta"
						20
						SCREEN-MODE)))
    	(gimp-image-insert-layer image layer 0 0)
    	; preenche camada
		(gimp-context-set-foreground '(232 101 179))
		(gimp-edit-fill layer 0)

		; adiciona camada azul
		(set! layer (car (gimp-layer-new image
						width
						height
						RGB-IMAGE
						"Blue"
						17
						SCREEN-MODE)))
    	(gimp-image-insert-layer image layer 0 0)
    	; preenche camada
		(gimp-context-set-foreground '(9 73 233))
		(gimp-edit-fill layer 0)

		; atualiza o display
		(gimp-displays-flush)

	)
)

; registra

(script-fu-register "emiliano-vintage-look"
		    "<Image>/Filters/Emi's/Vintage Look"
		    "Simple vintage look."
		    "Emiliano Sauvisky"
		    "Emiliano Sauvisky"
		    "2011-11-10"
		    "RGB*"
		    SF-IMAGE "Input Image" 0
)
