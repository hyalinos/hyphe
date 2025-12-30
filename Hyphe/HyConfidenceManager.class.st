"
Just a wrapper for confidence levels to add some logic to manipulate them
"
Class {
	#name : 'HyConfidenceManager',
	#superclass : 'Object',
	#instVars : [
		'levels'
	],
	#classInstVars : [
		'defaultLevels',
		'user'
	],
	#category : 'Hyphe-Inference',
	#package : 'Hyphe',
	#tag : 'Inference'
}

{ #category : 'accessing' }
HyConfidenceManager class >> defaultLevels [

	^ defaultLevels
]

{ #category : 'as yet unclassified' }
HyConfidenceManager class >> getLevelByScore: aScore [

	| level aNumber |
	
	aNumber := aScore asNumber. 
	level := defaultLevels select: [ :l |
		         l min <= aNumber and: l max >= aNumber ].
	level isNotEmpty ifTrue: [ ^ level first name ].
	^ 'undefined'
]

{ #category : 'accessing' }
HyConfidenceManager class >> initialize [ 

	self initializeDefaultLevels.
	self initializeUserSettings
		
	
]

{ #category : 'accessing' }
HyConfidenceManager class >> initializeDefaultLevels [

	defaultLevels := OrderedCollection new 
		add: (HyConfidenceLevel new name: 'Low'; min: 0.0; max: 0.6; yourself);
		add: (HyConfidenceLevel new name: 'Medium'; min: 0.61; max: 0.8; yourself);
		add: (HyConfidenceLevel new name: 'High'; min: 0.81; max: 1.0; yourself);
		yourself.
		
	
]

{ #category : 'accessing' }
HyConfidenceManager class >> initializeUserSettings [

	user := self new
		
	
]

{ #category : 'accessing' }
HyConfidenceManager class >> user [

	^ user
]

{ #category : 'as yet unclassified' }
HyConfidenceManager >> getLevelByScore: aScore [

	| level |
	level := levels select: [ :l |
		         l min <= aScore and: l max >= aScore ].
	level isNotEmpty ifTrue: [ ^ level name ].
	^ 'undefined'
]

{ #category : 'as yet unclassified' }
HyConfidenceManager >> initialize [ 

	levels := self class defaultLevels 
]

{ #category : 'accessing' }
HyConfidenceManager >> levels [

	^ levels
]
