Class {
	#name : 'HypheNECSettings',
	#superclass : 'Object',
	#category : 'Hyphe-Injection',
	#package : 'Hyphe',
	#tag : 'Injection'
}

{ #category : 'as yet unclassified' }
HypheNECSettings class >> extraSpacingForNEC [
^15
]

{ #category : 'as yet unclassified' }
HypheNECSettings class >> getColorForConfidence: aNumber [
^ (aNumber >= 0.81)
		ifTrue: [ self highConfidenceColor ]
		ifFalse: [ aNumber >= 0.61
			ifTrue: [ self mediumConfidenceColor ]
			ifFalse: [ self lowConfidenceColor ] ].
]

{ #category : 'as yet unclassified' }
HypheNECSettings class >> highConfidenceColor [
"This doesn't account for themes"
^Color R:5 G:210 B:0

]

{ #category : 'as yet unclassified' }
HypheNECSettings class >> lowConfidenceColor [
^Color R:200 G:50 B:0
]

{ #category : 'as yet unclassified' }
HypheNECSettings class >> mediumConfidenceColor [
^Color R:140 G:100 B:0
]
