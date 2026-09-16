Extension { #name : 'ARTHClassifier' }

{ #category : '*Hyphe' }
ARTHClassifier class >> hypheExporter [

	^ ARTHResultsExporter
]

{ #category : '*Hyphe' }
ARTHClassifier class >> runHypheInference: packageNames [
	"ARTH's report includes unmatched selectors too (expectedType = HTMUnknown) -- those
	 dissolve harmlessly here via HyHTMTypeNaming's empty-for-Unknown rule."

	| results |
	results := OrderedCollection new.
	packageNames do: [ :packageName |
			| report |
			report := self classifyPackage: packageName.
			report results do: [ :m |
					| names |
					names := HyHTMTypeNaming namesFor: m expectedType ownClassName: m className.
					names ifNotEmpty: [
							results add: {
									packageName.
									m className.
									m selector.
									names } ] ] ].
	^ results
]

{ #category : '*Hyphe' }
ARTHClassifier class >> tier [

	^ #heuristic
]
