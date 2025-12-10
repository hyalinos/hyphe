Extension { #name : 'TypeMe' }

{ #category : '*Hyphe' }
TypeMe class >> hypheExporter [

	self subclassResponsibility 
]

{ #category : '*Hyphe' }
TypeMe class >> runHypheInference: packageNames [

	|results| 
	results := (self new extractTypesForPackages: packageNames).
	
	(results conflicts) ifEmpty: [ ^ results typeResults ].
 
	^ (results conflicts) flatCollect: [ :conf |
		results typeResults reject: [:t |
			(((t at: 1) = (conf at: 1)) and: ( (t at: 2) = (conf at: 2)) ) and: ( (t at: 3) = (conf at: 3))
			  ] 
		 ].
	 
]
