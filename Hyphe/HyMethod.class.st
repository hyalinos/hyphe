Class {
	#name : 'HyMethod',
	#superclass : 'HyEntity',
	#instVars : [
		'name',
		'parameters',
		'returnTypes',
		'returnTypeConfidence',
		'selectedReturnType'
	],
	#category : 'Hyphe-Data',
	#package : 'Hyphe',
	#tag : 'Data'
}

{ #category : 'instance creation' }
HyMethod class >> fromJsonDictionary: aDict [
    | instance |
    instance := self new.
    instance name: (aDict at: 'name').
    
    "(aDict at: 'parameters' ifAbsent: [ #() ]) do: [ :paramDict |
        instance addParameter: (HyParameter fromJsonDictionary: paramDict) ]."
    
    (aDict at: 'returnTypes' ifAbsent: [ #() ]) do: [ :typeDict |
        instance addReturnType: (HyType fromJsonDictionary: typeDict) ].
    
    ^ instance
]

{ #category : 'accessing' }
HyMethod >> InferenceResultsExporter [

	^ returnTypeConfidence
]

{ #category : 'adding' }
HyMethod >> addReturnType: typeObj [

	typeObj source ifNotNil: [ 
		(self hasReturnTypesNamed: typeObj name fromSource: typeObj source)
		ifFalse: [
				returnTypes add: (HyType new
						 name: typeObj name;
						 source: typeObj source;
						 yourself) ] ]
	ifNil: [ 
		(self hasReturnTypesNamed: typeObj name)
		ifFalse: [
				returnTypes add: (HyType new
						 name: typeObj name;
						 yourself) ]
		 ].
]

{ #category : 'adding' }
HyMethod >> addReturnType: typeName source: sourceName [

	(self hasReturnTypesNamed: typeName fromSource: sourceName) 
		ifFalse: [ returnTypes add: (HyType new name: typeName; source: sourceName; yourself) ] 
]

{ #category : 'accessing' }
HyMethod >> asJsonDictionary [
    
	| dict |
 
   dict := Dictionary new
        at: 'name' put: name;
        yourself.
    
    parameters ifNotEmpty: [
        dict at: 'parameters' put: (parameters collect: [ :param | param asJsonDictionary ]) asArray ].
    returnTypes ifNotEmpty: [
        dict at: 'returnTypes' put: (returnTypes collect: [ :type | type asJsonDictionary ]) asArray ].
    
    ^ dict
]

{ #category : 'adding' }
HyMethod >> getReturnTypeNamed: typeName fromSource: sourceName [

	^ (returnTypes select: [ :t | t name = typeName and: t source = sourceName ]) first

]

{ #category : 'adding' }
HyMethod >> getReturnTypesNamed: typeName [

	^ returnTypes select: [ :t | t name = typeName ]

]

{ #category : 'adding' }
HyMethod >> hasReturnTypeFromSource: sourceName [

	^ returnTypes anySatisfy: [ :t | t source = sourceName ] 

]

{ #category : 'adding' }
HyMethod >> hasReturnTypesNamed: typeName [

 ^ returnTypes anySatisfy: [ :t | t name = typeName ] 

]

{ #category : 'adding' }
HyMethod >> hasReturnTypesNamed: typeName fromSource: sourceName [

	^ returnTypes anySatisfy: [ :t | t name = typeName and: t source = sourceName ]

]

{ #category : 'accessing' }
HyMethod >> initialize [

	super initialize.
	returnTypes := OrderedCollection new.
	parameters := OrderedCollection new
]

{ #category : 'accessing' }
HyMethod >> name [

	^ name
]

{ #category : 'accessing' }
HyMethod >> name: anObject [

	name := anObject
]

{ #category : 'accessing' }
HyMethod >> parameters [

	^ parameters
]

{ #category : 'accessing' }
HyMethod >> parameters: anObject [

	parameters := anObject
]

{ #category : 'accessing' }
HyMethod >> returnTypeConfidence [

	^ returnTypeConfidence
]

{ #category : 'accessing' }
HyMethod >> returnTypeConfidence: anObject [

	returnTypeConfidence := anObject
]

{ #category : 'accessing' }
HyMethod >> returnTypes [

	^ returnTypes
]

{ #category : 'accessing' }
HyMethod >> returnTypes: anObject [

	returnTypes := anObject
]

{ #category : 'accessing' }
HyMethod >> selectedReturnType [

	^ selectedReturnType
]

{ #category : 'accessing' }
HyMethod >> selectedReturnType: selectedType [

	selectedReturnType := selectedType 
]
