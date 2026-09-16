Extension { #name : 'TypeCollector' }

{ #category : '*Hyphe' }
TypeCollector class >> extractClassResults: aClass package: packageName into: results [
	"Runs RoelTyper over aClass (structural extraction + every method's return-type
	 resolution) in its own forked process with a wall-clock budget (maxSecondsPerClass).
	 If it doesn't finish in time, that class's process is terminated and its results are
	 discarded -- runHypheInference: moves on to the next class instead of hanging."

	| semaphore localResults timedOut classProcess |
	semaphore := Semaphore new.
	localResults := OrderedCollection new.
	classProcess := [
		                [
			                | packaged |
			                packaged := self typeInstvarsOfClass: aClass.
			                aClass methods do: [ :compiledMethod |
					                | key extractedType |
					                key := ('_' , compiledMethod selector , '>>^') asSymbol.
					                extractedType := packaged at: key ifAbsent: [ nil ].
					                extractedType ifNotNil: [
							                localResults add: {
									                packageName.
									                aClass name.
									                compiledMethod selector.
									                extractedType types } ] ] ]
			                on: Error
			                do: [ :ex |  ].
		                semaphore signal ] fork.

	timedOut := semaphore waitTimeoutSeconds: self maxSecondsPerClass.
	timedOut
		ifTrue: [ classProcess terminate ]
		ifFalse: [ results addAll: localResults ]
]

{ #category : '*Hyphe' }
TypeCollector class >> hypheExporter [

	^ RoelTyperResultsExporter
]

{ #category : '*Hyphe' }
TypeCollector class >> maxSecondsPerClass [
	"Per-class wall-clock budget for runHypheInference:. RoelTyper's own type resolution
	 (rootsUnderstanding:'s whole-image interface search, in particular) can be expensive
	 for a class with heavily duck-typed/cross-linked variables; this bounds how long any
	 one class is allowed to take before its results are skipped and the sweep moves on --
	 the same defense-in-depth this project already added for
	 HypheReturnsCollectorMethodNodes>>runTestCase:selector:."

	^ 20
]

{ #category : '*Hyphe' }
TypeCollector class >> runHypheInference: packageNames [
	"Extract each class's types via extractClassResults:package:into:, which bounds and
	 isolates the (structurally O(methods^2)-fixed but still potentially slow, see
	 maxSecondsPerClass's comment) per-class work so one gnarly class can't hang the whole
	 package sweep."

	| results |
	results := OrderedCollection new.
	packageNames do: [ :packageName |
			(PackageOrganizer default packageNamed: packageName) classes do: [ :aClass |
				self extractClassResults: aClass package: packageName into: results ] ].
	^ results
]

{ #category : '*Hyphe' }
TypeCollector class >> tier [

	^ #observation
]
