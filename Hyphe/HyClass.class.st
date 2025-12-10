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

{ #category : 'instance creation' }
HyClass class >> fromJsonDictionary: aDict [

	| instance |
	instance := self new.
	instance name: (aDict at: 'class').
	"instance superclass: (aDict at: 'superclass')."
	(aDict at: 'methods') do: [ :methodD |
		instance addMethod: (HyMethod fromJsonDictionary: methodD) ].
	"(aDict at: 'variables') do: [ :variableDict |
		instance addVariable: (HyVariable fromJsonDictionary: variableDict) ]."
	^ instance
]

{ #category : 'visiting' }
HyClass >> accept: visitor [

	methods do: [:m | visitor visitMethod: m  ]
]

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
HyClass >> asJsonDictionary [

	^ Dictionary new
		  at: 'class' put: name;
		  "at: 'superclass' put: superclass;"
		  at: 'variables' put: (variables collect: [ :var | var asJsonDictionary ]) asOrderedCollection;
        at: 'methods' put: (methods collect: [ :method | method asJsonDictionary ]) asOrderedCollection;
		  yourself
]

{ #category : 'adding' }
HyClass >> createMethod: methodName [

	^ methods add: (HyMethod new
			 name: methodName;
			 yourself)
]

{ #category : 'adding' }
HyClass >> findOrCreateMethod: methodName [

	(methods anySatisfy: [ :c | c name = methodName ])
		ifFalse: [ ^ self createMethod: methodName ]
		ifTrue: [ ^ self getMethodNamed: methodName ]
]

{ #category : 'adding' }
HyClass >> getMethodNamed: methodName [

	^ (methods select: [ :c | c name = methodName ]) first
]

{ #category : 'adding' }
HyClass >> hasMethodNamed: methodName [

	^ methods anySatisfy: [ :c | c name = methodName ] 
]

{ #category : 'initialization' }
HyClass >> initialize [

	super initialize.
	methods := OrderedCollection new.
	variables := OrderedCollection new
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
HyClass >> updateMethod: newMethod [

	| oldMethod |
	
	oldMethod := self getMethodNamed: (newMethod name).
	(oldMethod = newMethod) ifFalse: [ 
		"oldMethod updateParameters: newMethod parameters."
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

{ #category : 'accessing' }
HyClass >> variables [

	^ variables
]

{ #category : 'accessing' }
HyClass >> variables: anObject [

	variables := anObject
]
