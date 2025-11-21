Class {
	#name : 'HyType',
	#superclass : 'HyEntity',
	#instVars : [
		'name',
		'source'
	],
	#category : 'Hyphe-Data',
	#package : 'Hyphe',
	#tag : 'Data'
}

{ #category : 'accessing' }
HyType >> name [

	^ name
]

{ #category : 'accessing' }
HyType >> name: anObject [

	name := anObject
]

{ #category : 'accessing' }
HyType >> source [

	^ source
]

{ #category : 'accessing' }
HyType >> source: anObject [

	source := anObject
]

{ #category : 'accessing' }
HyType >> toJSON [

]
