Extension { #name : 'TypeCollector' }

{ #category : '*Hyphe' }
TypeCollector class >> hypheExporter [

	^ RoelTyperResultsExporter
]

{ #category : '*Hyphe' }
TypeCollector class >> runHypheInference: packageNames [

|results|

results := OrderedCollection new.	
packageNames do: [ :packageName | 
			((PackageOrganizer default packageNamed: packageName) classes ) do: [ :aClass |
			  aClass methods collect: [ :compiledMethod |
				results add: { packageName . aClass name . compiledMethod selector . ((self typeTmpsIn:  compiledMethod) at: '^' asSymbol) types}
				]
			]
		].
^ results
]

{ #category : '*Hyphe' }
TypeCollector class >> tier [

	^ #observation
]
