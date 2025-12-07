Class {
	#name : 'HypheReturnDataItem',
	#superclass : 'Object',
	#instVars : [
		'receiverClass',
		'methodSelector',
		'definingClass',
		'returnClass'
	],
	#category : 'Hyphe',
	#package : 'Hyphe'
}

{ #category : 'accessing' }
HypheReturnDataItem >> definingClass [
    ^ definingClass
]

{ #category : 'accessing' }
HypheReturnDataItem >> definingClass: aClass [
    definingClass := aClass
]

{ #category : 'accessing' }
HypheReturnDataItem >> methodSelector [
    ^ methodSelector
]

{ #category : 'accessing' }
HypheReturnDataItem >> methodSelector: aSelector [
    methodSelector := aSelector
]

{ #category : 'printing' }
HypheReturnDataItem >> printOn: aStream [
    aStream
        nextPutAll: receiverClass printString;
        nextPutAll: ' >> ';
        nextPutAll: methodSelector printString;
        nextPutAll: ' (in ';
        nextPutAll: definingClass printString;
        nextPutAll: ') returns ';
        nextPutAll: returnClass printString
]

{ #category : 'accessing' }
HypheReturnDataItem >> receiverClass [
    ^ receiverClass
]

{ #category : 'accessing' }
HypheReturnDataItem >> receiverClass: aClass [
    receiverClass := aClass
]

{ #category : 'accessing' }
HypheReturnDataItem >> returnClass [
    ^ returnClass
]

{ #category : 'accessing' }
HypheReturnDataItem >> returnClass: aClass [
    returnClass := aClass
]
