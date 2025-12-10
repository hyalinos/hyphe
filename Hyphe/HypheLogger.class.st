Class {
	#name : 'HypheLogger',
	#superclass : 'Object',
	#category : 'Hyphe-Injection',
	#package : 'Hyphe',
	#tag : 'Injection'
}

{ #category : 'streaming' }
HypheLogger class >> cr [
self enabled ifFalse: [ ^self ].
Transcript cr
]

{ #category : 'accessing' }
HypheLogger class >> enabled [
"change this to true or false to enable or disable Transcript logging"
^true
]

{ #category : 'streaming' }
HypheLogger class >> show: aMessage [
self enabled ifFalse: [ ^self ].
Transcript show: aMessage
]

{ #category : 'streaming' }
HypheLogger class >> showCr: aMessage [
self enabled ifFalse: [ ^self ].
Transcript showCr: aMessage
]
