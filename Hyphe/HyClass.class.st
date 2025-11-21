Class {
	#name : 'HyClass',
	#superclass : 'HyEntity',
	#instVars : [
		'name',
		'superclass',
		'methods',
		'variables'
	],
	#category : 'Hyphe-Data',
	#package : 'Hyphe',
	#tag : 'Data'
}

{ #category : 'adding' }
HyClass >> addMethod: methodObj [

(self hasMethodNamed: methodObj name) 
		ifTrue: [ self updateMethod: (self getMethodNamed: methodObj name) ]
		ifFalse: [ self methods add: methodObj ]
]

{ #category : 'adding' }
HyClass >> addMethods: methodsCollection [

	self methods ifEmpty: [^ self methods add: methodsCollection; yourself].
	methodsCollection do: [ : newMethod | self addMethod: newMethod]
]

{ #category : 'adding' }
HyClass >> getMethodNamed: methodName [

	^ (methods select: [ :c | c name = methodName ]) first
]

{ #category : 'adding' }
HyClass >> hasMethodNamed: methodName [

	^ methods anySatisfy: [ :c | c name = methodName ] 
]

{ #category : 'accessing' }
HyClass >> methods [

	^ methods
]

{ #category : 'accessing' }
HyClass >> methods: anObject [

	methods := anObject
]

{ #category : 'accessing' }
HyClass >> name [

	^ name
]

{ #category : 'accessing' }
HyClass >> name: anObject [

	name := anObject
]

{ #category : 'adding' }
HyClass >> removeMethod: methodObj [

	(self hasMethodNamed: methodObj name) 
		ifTrue: [ methods remove: (self getMethodNamed: methodObj name) ]
]

{ #category : 'adding' }
HyClass >> removeMethodNamed: methodName [

	(self hasMethodNamed: methodName) 
		ifTrue: [ methods remove: (self getMethodNamed: methodName) ]
]

{ #category : 'accessing' }
HyClass >> superclass [

	^ superclass
]

{ #category : 'accessing' }
HyClass >> superclass: anObject [

	superclass := anObject
]

{ #category : 'adding' }
HyClass >> toJSON [ 
]

{ #category : 'adding' }
HyClass >> updateMethod: newMethod [

	| oldMethod |
	
	oldMethod := self getMethodNamed: (newMethod name).
	(oldMethod equals: newMethod) ifFalse: [ 
		oldMethod updateParameters: newMethod parameters.
		oldMethod updataReturnTypes: newMethod returnTypes.
	]
]

{ #category : 'adding' }
HyClass >> updateMethods: newMethodsCollection [

	newMethodsCollection do: [ :newMethod | self updateMethod: newMethod ]
]

{ #category : 'accessing' }
HyClass >> updateVariables: newVariables [
	
]
