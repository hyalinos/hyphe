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

{ #category : 'instance creation' }
HyType class >> fromJsonDictionary: aDict [
    
	| instance |
 
   instance := self new.
    instance name: (aDict at: 'type').
    instance source: (aDict at: 'source').
    
    "(aDict at: 'blockSignatures' ifAbsent: [ nil ]) ifNotNil: [ :sigArray |
        sigArray do: [ :sigDict |
            instance addBlockSignature: (HyBlockSignature fromJsonDictionary: sigDict) ] ]."
    
    ^ instance
]

{ #category : 'accessing' }
HyType >> asJsonDictionary [
    | dict |

    dict := Dictionary new
        at: 'type' put: name;
        at: 'source' put: source;
        yourself.
    
	"blockSignatures ifNotNil: [
        dict at: 'blockSignatures' put: (blockSignatures collect: [ :sig | sig asJsonDictionary ]) asArray ]."
    
    ^ dict
]

{ #category : 'comparing' }
HyType >> equals: type [

	(type class = self class) ifFalse: [ ^ false ].
	(type source = source) ifFalse: [ ^ false ].
	(type name = name) ifFalse: [ ^ false ].
	^ true.
]

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
