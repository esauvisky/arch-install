;Bar�th G�bor <dincsi@gmail.com>, 2007
; License:
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; The GNU Public License is available at
; http://www.gnu.org/copyleft/gpl.html

(define (silicosaur-photofx-portra image drawable)

	(define (set-pt a index x y)
		(aset a (* index 2) x)
		(aset a (+ (* index 2) 1) y)
	)


	(define (splineValue)
		(let* ((v (cons-array 8 'byte)))
			(set-pt v 0 0 0 )
			(set-pt v 1 23 20 )
			(set-pt v 2 157 173 )
			(set-pt v 3	255 255 )
			v
			)
	)

	(define (splineRed)
		(let* ((r (cons-array 8 'byte)))
			(set-pt r 0 0 0 )
			(set-pt r 1 69 69 )
			(set-pt r 2 213 218 )
			(set-pt r 3 255 255 )
			r
			)
	)

	(define (splineGreen)
		(let* ((g (cons-array 8 'byte)))
			(set-pt g 0 0 0 )
			(set-pt g 1 52 47 )
			(set-pt g 2 189 196 )
			(set-pt g 3 255 255 )
			g
			)
	)

	(define (splineBlue)
		(let* ((b (cons-array 8 'byte)))
			(set-pt b 0 0 20 )
			(set-pt b 1 41 46 )
			(set-pt b 2 231 228 )
			(set-pt b 3 255 255 )
			b
			)
	)

	(define (splineGamma)
		(let* ((a (cons-array 4 'byte)))
			(set-pt a 0 0 0 )
			(set-pt a 1 255 255 )
			a
			)
	)
	(gimp-image-undo-group-start image)

	(gimp-curves-spline drawable 0 8 (splineValue))
	(gimp-curves-spline drawable 1 8 (splineRed))
	(gimp-curves-spline drawable 2 8 (splineGreen))
	(gimp-curves-spline drawable 3 8 (splineBlue))
	;(gimp-curves-spline drawable 4 4 (splineGamma))

	(gimp-image-undo-group-end image)

	(gimp-displays-flush)
)

(script-fu-register "silicosaur-photofx-portra"
		    "<Image>/Filters/Emi's/PhotoFX/Portra"
		    "Kodak Portra film effect."
		    "dincsi"
		    "dincsi"
		    "2007-10-10"
		    "RGB*"
		    SF-IMAGE "Input Image" 0
		    SF-DRAWABLE "Input Drawable" 0
)