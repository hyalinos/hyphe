"
I convert an HTMType (Hyphe-TypeModel, shared by ARTI/ARTH/CTI) into a small OrderedCollection of plain Pharo class-name Strings, for tools whose runHypheInference: feeds the generic HyResultsExporter/groupTypeResults: pipeline, which only understands raw type-name strings, not HTMType's own object shape. Bottom/Unknown/TypeVar carry no informative Pharo class name for that pipeline and are dropped (empty result, so the caller skips the method entirely) -- this mirrors how TypeMe/TypeCollector/OfflineProfiler already only report methods they have something concrete to say about. HTMSelf/HTMSelfClass are resolved via the ownClassName the caller passes in, since HTMType itself does not carry the receiver's name.
"
Class {
	#name : 'HyHTMTypeNaming',
	#superclass : 'Object',
	#category : 'Hyphe',
	#package : 'Hyphe'
}

{ #category : 'converting' }
HyHTMTypeNaming class >> namesFor: anHTMType ownClassName: aString [
	"Bottom/Unknown/TypeVar: no informative Pharo class name for Hyphe's plain-string
	 type model -- return empty so the caller skips this method rather than reporting a
	 synthetic, non-class token."

	(anHTMType isKindOf: HTMClassRef) ifTrue: [ ^ OrderedCollection with: anHTMType className asString ].
	(anHTMType isKindOf: HTMMetaclass) ifTrue: [ ^ OrderedCollection with: anHTMType className asString , ' class' ].
	(anHTMType isKindOf: HTMSelf) ifTrue: [ ^ OrderedCollection with: aString ].
	(anHTMType isKindOf: HTMSelfClass) ifTrue: [ ^ OrderedCollection with: aString , ' class' ].
	(anHTMType isKindOf: HTMUnion) ifTrue: [
		^ (anHTMType types flatCollect: [ :t | self namesFor: t ownClassName: aString ]) asSet asOrderedCollection ].
	^ OrderedCollection new
]
