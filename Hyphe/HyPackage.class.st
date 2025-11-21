Class {
	#name : 'HyPackage',
	#superclass : 'HyEntity',
	#instVars : [
		'name',
		'classes'
	],
	#category : 'Hyphe-Data',
	#package : 'Hyphe',
	#tag : 'Data'
}

{ #category : 'adding' }
HyPackage >> addClass: newClass [

	(self hasClassNamed: newClass name) 
		ifTrue: [ self updateClass: (self getClassNamed: newClass name) ]
		ifFalse: [ self classes add: newClass ]
		
]

{ #category : 'adding' }
HyPackage >> addClassNamed: className [

	(self hasClassNamed: className) ifFalse: [ self classes add: (HyClass new name: className; yourself) ]
		
]

{ #category : 'adding' }
HyPackage >> addClasses: newClasses [

	self classes ifEmpty: [^ self classes add: newClasses; yourself].
	newClasses do: [ : newClass | self addClass: newClass]
]

{ #category : 'adding' }
HyPackage >> classes [

	^ classes 
]

{ #category : 'accessing' }
HyPackage >> classes: anObject [

	classes := anObject
]

{ #category : 'comparing' }
HyPackage >> equals: aPackage [

	(name = aPackage name) ifFalse: [^ false].
	(classes size = aPackage size) ifFalse: [ ^ false ].
	(classes anySatisfy: [ :cl1 | (aPackage classes anySatisfy: [ :cl2 | cl1 equals: cl2 ]) not ]) ifTrue: [ ^ false ].
	^ true. 
]

{ #category : 'adding' }
HyPackage >> getClassNamed: className [

	^ (classes select: [ :c | c name = className ]) first
]

{ #category : 'adding' }
HyPackage >> hasClassNamed: className [

	^ classes anySatisfy: [ :c | c name = className ] 
]

{ #category : 'adding' }
HyPackage >> initialize [ 

	classes := OrderedCollection new. 
]

{ #category : 'accessing' }
HyPackage >> name [

	^ name
]

{ #category : 'accessing' }
HyPackage >> name: anObject [

	name := anObject
]

{ #category : 'adding' }
HyPackage >> removeClass: newClass [

	(self hasClassNamed: newClass name) 
		ifTrue: [ classes remove: (self getClassNamed: newClass name) ]
		
]

{ #category : 'adding' }
HyPackage >> removeClassNamed: className [

	(self hasClassNamed: className) 
		ifTrue: [ classes remove: (self getClassNamed: className) ]
		
]

{ #category : 'as yet unclassified' }
HyPackage >> toJSON [ 
]

{ #category : 'as yet unclassified' }
HyPackage >> updateClass: newClass [

	| oldClass |
	
	oldClass := self getClassNamed: (newClass name).
	(oldClass equals: newClass) ifFalse: [ 
		oldClass updateVariables: newClass variables.
		oldClass updateMethods: newClass methods. 
	]
]

{ #category : 'as yet unclassified' }
HyPackage >> updateClasses: newClasses [

	newClasses do: [ :newClass | self updateClass: newClass ]

]
