Extension { #name : 'J2Literal' }

{ #category : '*Hyphe' }
J2Literal >> accept: aVisitor [ 
	
	^ aVisitor visitJ2Literal: self
]
