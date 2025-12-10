Class {
	#name : 'HyCollectedType',
	#superclass : 'Object',
	#instVars : [
		'package',
		'claz',
		'method',
		'types',
		'confidenceScore',
		'confidenceLevel',
		'sources'
	],
	#category : 'Hyphe-Data',
	#package : 'Hyphe',
	#tag : 'Data'
}

{ #category : 'instance creation' }
HyCollectedType class >> fromJsonDictionary: typeDict [
 
	^ self new
		package: (typeDict at: 'package');
		claz: (typeDict at: 'class');
		method: (typeDict at: 'method');
		types: (typeDict at: 'types');
		sources: (typeDict at: 'sources');
		confidenceLevel: (typeDict at: 'confidenceLevel');
		confidenceScore: (typeDict at: 'confidenceScore');
		yourself.
		

    
]

{ #category : 'visiting' }
HyCollectedType >> accept: visitor [

	visitor collectedData add: (Dictionary new
			 at: #packageName put: package;
			 at: #className put: claz;
			 at: #methodName put: method;
			 at: #type put: types;
			 at: #confidence put: confidenceScore ;
			 at: #level
			 put: confidenceLevel;
			 at: #sources put: sources;
			 yourself)
]

{ #category : 'converting' }
HyCollectedType >> asJsonDictionary [

	^ Dictionary new
        at: 'package' put: package;
		  at: 'class' put: claz;
		  at: 'method' put: method;
		  at: 'types' put: types;
		  at: 'confidenceScore' put: confidenceScore;
		  at: 'confidenceLevel' put: confidenceLevel; 
        at: 'sources' put: sources;
        yourself.


]

{ #category : 'accessing' }
HyCollectedType >> claz [

	^ claz
]

{ #category : 'accessing' }
HyCollectedType >> claz: anObject [

	claz := anObject
]

{ #category : 'accessing' }
HyCollectedType >> confidenceLevel [

	^ confidenceLevel
]

{ #category : 'accessing' }
HyCollectedType >> confidenceLevel: anObject [

	confidenceLevel := anObject
]

{ #category : 'accessing' }
HyCollectedType >> confidenceScore [

	^ confidenceScore
]

{ #category : 'accessing' }
HyCollectedType >> confidenceScore: anObject [

	confidenceScore := anObject
]

{ #category : 'accessing' }
HyCollectedType >> method [

	^ method
]

{ #category : 'accessing' }
HyCollectedType >> method: anObject [

	method := anObject
]

{ #category : 'accessing' }
HyCollectedType >> package [

	^ package
]

{ #category : 'accessing' }
HyCollectedType >> package: anObject [

	package := anObject
]

{ #category : 'accessing' }
HyCollectedType >> sources [

	^ sources
]

{ #category : 'accessing' }
HyCollectedType >> sources: anObject [

	sources := anObject
]

{ #category : 'accessing' }
HyCollectedType >> types [

	^ types
]

{ #category : 'accessing' }
HyCollectedType >> types: anObject [

	types := anObject
]
