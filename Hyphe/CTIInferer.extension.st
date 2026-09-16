Extension { #name : 'CTIInferer' }

{ #category : '*Hyphe' }
CTIInferer class >> hypheExporter [

	^ CTIResultsExporter
]

{ #category : '*Hyphe' }
CTIInferer class >> runHypheInference: packageNames [
	"CTI is interprocedural (inferPackage: pulls in its whole reachable universe to seed
	 from), so -- same as HYIToolAdapter class>>addCTIResultsFor:into: already does in
	 Hyphe-Inferencer -- only entries actually declared on a class of this package (or its
	 metaclass) are kept; the rest is CTI's own working set, not results for this scope."

	| results |
	results := OrderedCollection new.
	packageNames do: [ :packageName |
			| engine classesInPackage |
			engine := self inferPackage: packageName.
			classesInPackage := Smalltalk allClasses select: [ :c |
					                    [ c package name = packageName ]
						                    on: Error
						                    do: [ :e | false ] ].
			classesInPackage do: [ :aClass |
					(Array with: aClass with: aClass class) do: [ :behavior |
							| own |
							own := engine methodInfos at: behavior ifAbsent: [ nil ].
							own ifNotNil: [
									own keysAndValuesDo: [ :sel :info |
											| tau names |
											tau := engine typeFor: info returnVar minBits.
											names := HyHTMTypeNaming namesFor: tau ownClassName: aClass name.
											names ifNotEmpty: [
													results add: {
															packageName.
															aClass name.
															sel.
															names } ] ] ] ] ] ].
	^ results
]

{ #category : '*Hyphe' }
CTIInferer class >> tier [

	^ #observation
]
