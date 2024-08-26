(define (emiliano-after-edit text input output) 
	(let* 	(	
				(image 		(car (file-jpeg-load 1 input output)))
				(drawable 	(car (gimp-image-active-drawable image)))
				(width 		(car (gimp-image-width image)))
				(height 	(car (gimp-image-height image)))
				(radius		(round (/ (max width height) 60)))
				(l-height	())
				(l-width	())
				(a-vector	())
				(layer		())
				(l-texto	())
				(opacidade	100)
			)
		; converte para RGB
		(if (= (car (gimp-drawable-is-rgb drawable)) FALSE) (gimp-image-convert-rgb image) )
		; criar texto em novo layer
		(gimp-context-swap-colors)
		(gimp-text-fontname image -1 5 5 text -1 TRUE (round (* height 0.02)) 0 "Linux Biolinum O Bold")
		(set! l-texto	(car (gimp-image-get-active-layer image)))
		(gimp-layer-set-opacity l-texto opacidade)
		; adicionar vetor para outline
		(set! a-vector	(car (gimp-vectors-new-from-text-layer image l-texto)))
		(gimp-image-add-vectors image a-vector -1)
		; criar camada de outline com canal alfa e sem preenchimento
		(set! layer		(car (gimp-layer-new image width height 0 "outline" 100 0)))
		(gimp-layer-add-alpha layer)
		(gimp-image-add-layer image layer 1)
		(gimp-edit-clear layer)
		(gimp-layer-set-opacity layer opacidade)
		; vetor para seleção criar bordas e preencher seleção com cor de background
		(gimp-vectors-to-selection a-vector 2 TRUE FALSE 0 0)
		(gimp-selection-grow image (round (* height 0.001)))
		(set! drawable 	(car (gimp-image-get-active-drawable image)))
		(gimp-edit-fill drawable BACKGROUND-FILL)
		; mescla os canais do texto e do outline, cropa a camada do texto e deseleciona tudo.
		(gimp-image-merge-down image l-texto 0)
		(set! layer		(car (gimp-image-get-active-layer image)))
		(plug-in-autocrop-layer 1 image layer)
		(gimp-selection-none image)
		; rotaciona o texto e alinha no canto inferior esquerdo (em vertical)
		(set! layer		(car (gimp-image-get-active-layer image)))
		(plug-in-rotate 1 image layer 1 FALSE)
		(set! l-width	(car (gimp-drawable-width layer)))
		(set! l-height	(car (gimp-drawable-height layer)))		
		(gimp-layer-set-offsets layer (* height 0.002) (- height l-height radius))
		(gimp-context-swap-colors)
		; achata imagem e cria cantos arredondados
		(set! drawable 	(car (gimp-image-flatten image)))
	 	(script-fu-round-corners image drawable radius 0 0 0 0 0 0)
	 	; achata a imagem e salva como jpeg
		(set! drawable 	(car (gimp-image-flatten image)))
		(file-jpeg-save 1 image drawable output output 0.85 0 1 1 "(C) Emiliano Sauvisky." 0 1 0 0)

;		PARA DEBUG
;		(set! drawable 	(car (gimp-image-get-active-drawable image)))
;		(gimp-xcf-save 1 image drawable output output)
	)
)
