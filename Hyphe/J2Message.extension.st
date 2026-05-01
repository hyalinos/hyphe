Extension { #name : 'J2Message' }

{ #category : '*Hyphe' }
J2Message >> accept: aVisitor [
	"for the moment we do not process messages"

	^ aVisitor visitJ2Message: self
]
