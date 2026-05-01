Extension { #name : 'J2Variable' }

{ #category : '*Hyphe' }
J2Variable >> accept: aVisitor [

	^ aVisitor visitJ2Variable: self
]
