Extension { #name : 'TITMethodReturnTypesGatherer' }

{ #category : '*Hyphe' }
TITMethodReturnTypesGatherer class >> hypheExporter [ 

	^ TITResultsExporter
]

{ #category : '*Hyphe' }
TITMethodReturnTypesGatherer class >> runHypheInference: packageNames [

	|inst|
	inst := self new.
	^ packageNames flatCollect: [:p | inst gatherPackage: p ].
	
]

{ #category : '*Hyphe' }
TITMethodReturnTypesGatherer class >> tier [
 
	^#observation
]
