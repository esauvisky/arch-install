;
; Tri-Tone
;
; Autor: desconhecido.
; Editado em 10 novembro 2011 por Emiliano.

; A simple script to emulate darkroom toning (and other similar
; toning processes) with three colours (one of them is black). This
; code is based on the duotone script written by Alexios Chouchoulas.
; See http://www.bedroomlan.org/coding/duotone-gimp-script.
;
;
; Define the function:

(define (script-fu-tritone
				inImage
				inLayer
				inTintColour1
				inTintColour2
				inCopy
                inFlatten
	)

  (let* (
	 (theWidth (car (gimp-image-width inImage)))
	 (theHeight (car (gimp-image-height inImage)))
	 (theImage (if (= inCopy TRUE)
		       (car (gimp-image-duplicate inImage))
                       inImage))
	 (theLayer 0)
	 (mask 0)
	 )

    (if (< 0 (car (gimp-image-base-type theImage)))
	(gimp-image-convert-rgb theImage))

	; Do the actual work.

	; Copy the image.

    (gimp-selection-all theImage)
    (gimp-edit-copy inLayer)

	; =====================================
	; Make the tint layer for brighter areas
	; =====================================

    (set! theLayer (car (gimp-layer-new 	theImage
						theWidth
						theHeight
						RGBA-IMAGE
						"Tint"
						100
						COLOR-MODE)))
    (gimp-image-insert-layer theImage theLayer 0 0)

	; Fill the layer with the tint

    (gimp-context-set-foreground inTintColour1)
    (gimp-edit-fill theLayer 0)

	; Add the layer to the image

	; Create a mask for the new layer

    (set! mask (car (gimp-layer-create-mask theLayer ADD-WHITE-MASK)))
    (gimp-layer-add-mask theLayer mask)
    (gimp-floating-sel-anchor (car (gimp-edit-paste mask TRUE)))

	; =====================================
	; Make the tint layer for darker areas
	; =====================================

    (set! theLayer (car (gimp-layer-new 	theImage
						theWidth
						theHeight
						RGBA-IMAGE
						"Tint"
						100
						COLOR-MODE)))
    (gimp-image-insert-layer theImage theLayer 0 0)

	; Fill the layer with the tint

    (gimp-context-set-foreground inTintColour2)
    (gimp-edit-fill theLayer 0)

	; Add the layer to the image

	; Create a mask for the new layer

    (set! mask (car (gimp-layer-create-mask theLayer ADD-WHITE-MASK)))
    (gimp-layer-add-mask theLayer mask)
    (gimp-floating-sel-anchor (car (gimp-edit-paste mask TRUE)))
	(gimp-invert mask)

	; Flatten the image, if we need to.

    (if (= inFlatten TRUE) (gimp-image-flatten theImage))

	; Have we been working on a copy? If so display the new image.

    (if (= inCopy TRUE)
	(begin
	  (gimp-image-clean-all theImage)
	  (gimp-display-new theImage)
	  )
	()
	)

	; The end.

    (gimp-displays-flush)

    )					; End let*
)

; Register the function with the GIMP:

(script-fu-register
    "script-fu-tritone"
    _"<Image>/Filters/Emi's/Tri-Tone"
    "Produces a tri-tone photograph

Some interesting values for the colour are Sepia (162 138 101) and Selenium (229 232 234). Play with the colour saturation for more interesting effects, or uncheck the Flatten box and then modify the new layer's opacity. "
    "Paul Wellner Bou, using Alexios Chouchoulas' Duotone Script"
    "2009, Paul Wellner Bou"
    "May 5th, 2009"
    "RGB* GRAY* INDEXED*"
    SF-IMAGE       "The Image"      0
    SF-DRAWABLE    "The Layer"      0
    SF-COLOR       _"Tint colour for bright areas"   '(218 132 0)
	SF-COLOR       _"Tint colour for dark areas"   '(0 140 234)
    SF-TOGGLE      _"Work on Copy"  FALSE
    SF-TOGGLE      _"Flatten Image" FALSE
)

;;; End Of File.
