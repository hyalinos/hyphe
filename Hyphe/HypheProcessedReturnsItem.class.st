Class {
	#name : 'HypheProcessedReturnsItem',
	#superclass : 'Object',
	#instVars : [
		'receiverClass',
		'methodSelector',
		'definingClass',
		'returnsInfo',
		'package'
	],
	#category : 'Hyphe-CollectorsProcessing',
	#package : 'Hyphe',
	#tag : 'CollectorsProcessing'
}

{ #category : 'adding' }
HypheProcessedReturnsItem >> addReturnsInfo: aHypheReturnsInfo [
    returnsInfo add: aHypheReturnsInfo
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> definingClass [
    ^ definingClass
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> findSuperClass [
	
	    | aCollectionOfClasses currentClass candidates |
    
    aCollectionOfClasses := returnsInfo collect: [: r | r returnClass ].
    aCollectionOfClasses ifEmpty: [ ^ nil ].
    aCollectionOfClasses size = 1 ifTrue: [ ^ aCollectionOfClasses first ].
    
    "Start with the first class and get all its superclasses"
    currentClass := aCollectionOfClasses first.
    candidates := currentClass withAllSuperclasses.
    
    "For each remaining class, keep only the superclasses that are common"
    aCollectionOfClasses allButFirst do: [ :eachClass |
        candidates := candidates select: [ :superclass |
            eachClass withAllSuperclasses includes: superclass ] ].
    
    "Return the most specific common superclass (first in the list)"
    ^ candidates first

	
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> mergeTypes: superClass [

	self returnsInfo: (OrderedCollection new add: (
	HypheReturnsInfo new count: self timesCalled; percentage: 1; returnClass: superClass; yourself);yourself)
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> methodSelector [
    ^ methodSelector
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> optimizeTypes [

	|superClass|
	
	superClass := self findSuperClass.
	(superClass = Object) ifTrue: [ ^ false ].
	self mergeTypes: superClass.
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> package [
    ^ package
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> package: aPackage [
    package := aPackage
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> receiverClass [
    ^ receiverClass
]

{ #category : 'initialization' }
HypheProcessedReturnsItem >> receiverClass: aReceiverClass methodSelector: aSelector definingClass: aDefiningClass [
    receiverClass := aReceiverClass.
    methodSelector := aSelector.
    definingClass := aDefiningClass.
    returnsInfo := OrderedCollection new
]

{ #category : 'resolving' }
HypheProcessedReturnsItem >> resolvePackage [
    "Look up the package from the compiled method in definingClass"
    | compiledMethod |
    compiledMethod := definingClass >> methodSelector.
    compiledMethod ifNotNil: [
        package := compiledMethod package name ]
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> returnsInfo [
    ^ returnsInfo
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> returnsInfo: aCollection [
    returnsInfo := aCollection
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> timesCalled [

	^ self returnsInfo sum: [:r | r count ]
]
