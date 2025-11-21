Class {
	#name : 'HyMethod',
	#superclass : 'HyEntity',
	#instVars : [
		'name',
		'parameters',
		'returnTypes'
	],
	#category : 'Hyphe-Data',
	#package : 'Hyphe',
	#tag : 'Data'
}

{ #category : 'adding' }
HyMethod >> addReturnType: typeName source: sourceName [

	(returnTypes hasReturnTypesNamed: typeName fromSource: sourceName) 
		ifFalse: [ returnTypes add: (HyType new name: typeName; source: sourceName; yourself) ] 
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
HyMethod >> returnTypes [

	^ returnTypes
]

{ #category : 'accessing' }
HyMethod >> returnTypes: anObject [

	returnTypes := anObject
]

{ #category : 'accessing' }
HyMethod >> toJSON [
]
