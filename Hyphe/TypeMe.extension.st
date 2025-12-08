Extension { #name : 'TypeMe' }

{ #category : '*Hyphe' }
TypeMe class >> hypheExporter [

	self subclassResponsibility 
]

{ #category : '*Hyphe' }
TypeMe class >> runHypheInference: packageNames [

	|results| 
	results := (self new extractTypesForPackages: packageNames).
	^ results typeResults copyWithoutAll: results conflicts 
	 
]
