Extension { #name : 'ARTIReturnTypeInferrer' }

{ #category : '*Hyphe' }
ARTIReturnTypeInferrer class >> hypheExporter [

	^ ARTIResultsExporter
]

{ #category : '*Hyphe' }
ARTIReturnTypeInferrer class >> runHypheInference: packageNames [
	"Sec 4 of ARTI's own facade: inferPackage: takes one package name and returns an
	 ARTIInferenceReport whose results already exclude methods ARTI has nothing to say
	 about (primitive/empty) -- so the only extra filtering needed here is dropping
	 results whose HTM type carries no plain class name (see HyHTMTypeNaming)."

	| results |
	results := OrderedCollection new.
	packageNames do: [ :packageName |
			| report |
			report := self inferPackage: packageName.
			report results do: [ :m |
					| names |
					names := HyHTMTypeNaming namesFor: m type ownClassName: m className.
					names ifNotEmpty: [
							results add: {
									packageName.
									m className.
									m selector.
									names } ] ] ].
	^ results
]

{ #category : '*Hyphe' }
ARTIReturnTypeInferrer class >> tier [

	^ #structural
]
