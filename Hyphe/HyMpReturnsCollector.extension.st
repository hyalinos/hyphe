Extension { #name : 'HyMpReturnsCollector' }

{ #category : '*Hyphe' }
HyMpReturnsCollector class >> hypheExporter [

	^ OfflineProfilerResultsExporter
]

{ #category : '*Hyphe' }
HyMpReturnsCollector class >> runHypheInference: packageNames [
	"Drop-in replacement for HypheReturnsCollectorMethodNodes class>>runHypheInference:,
	 same protocol HyInferenceToolsManager/InferenceExecutor expect (tier, hypheExporter,
	 and this method returning an OrderedCollection of {package. className. selector.
	 typeName} tuples that HyResultsExporter>>groupTypeResults: consumes directly).
	 Processes all packageNames together in one sweep (see runOnPackages:) so domain
	 code and its companion test package are exercised together. Tuples key by
	 definingClass rather than receiverClass -- an inherited method exercised through
	 many receiver subclasses contributes one merged set of observed types instead of
	 duplicating across each receiver (see HyMpMethodProfile's class comment) -- and
	 packageName is read from the defining class's own package, not the sweep argument,
	 since a combined multi-package sweep has no single outer package to tag with."

	| collector report tuples |
	collector := self runOnPackages: packageNames.
	report := HyMpReturnTypeReport fromObservations: collector observations.
	tuples := OrderedCollection new.
	report profiles do: [ :profile |
			| packageName |
			packageName := profile definingClass package ifNil: [ 'Unknown' ] ifNotNil: [ :pkg | pkg name ].
			profile typeCounts keysDo: [ :returnClass |
					tuples add: {
							packageName.
							profile definingClass name.
							profile selector.
							returnClass name } ] ].
	^ tuples
]

{ #category : '*Hyphe' }
HyMpReturnsCollector class >> tier [

	^ #observation
]
