"
An abstract class for storing intermidiate representation on the pharo structural elements (e.g package, class, method, variable etc) and any available type-related information. Needed to unify information from different inference sources.
"
Class {
	#name : 'HyEntity',
	#superclass : 'Object',
	#category : 'Hyphe-Data',
	#package : 'Hyphe',
	#tag : 'Data'
}

{ #category : 'instance creation' }
HyEntity class >> fromJsonDictionary: aDict [
	self subclassResponsibility 
]

{ #category : 'converting' }
HyEntity >> asJsonDictionary [ 
	self subclassResponsibility 
]
