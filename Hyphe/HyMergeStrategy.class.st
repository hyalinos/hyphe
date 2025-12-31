Class {
	#name : 'HyMergeStrategy',
	#superclass : 'Object',
	#instVars : [
		'mergeResults',
		'tools'
	],
	#category : 'Hyphe-Merge',
	#package : 'Hyphe',
	#tag : 'Merge'
}

{ #category : 'as yet unclassified' }
HyMergeStrategy class >> prettyName [ 

	self subclassResponsibility 
]

{ #category : 'as yet unclassified' }
HyMergeStrategy >> checkForConfidentType: typesCollection [
 
	^ typesCollection select: [:t | t source = #TypeMeConfident  ]
]

{ #category : 'as yet unclassified' }
HyMergeStrategy >> extractToolConfidence: hyType [
     
   ^ (HyConfidenceManager getToolByName: (hyType source)) confidence.
    
]

{ #category : 'as yet unclassified' }
HyMergeStrategy >> extractToolConfidences: hyTypes [
      
    ^ hyTypes collect: [ :hyType | self extractToolConfidence: hyType].
   
]

{ #category : 'initialization' }
HyMergeStrategy >> findAgreeingSourcesFor: selectedType in: typesCollection [ 

	^ (typesCollection select: [ :hyType | hyType name = selectedType ]) collect: [ :hyType | hyType source ]
]

{ #category : 'initialization' }
HyMergeStrategy >> initialize [
    super initialize.
]

{ #category : 'initialization' }
HyMergeStrategy >> mergeTypes: typesCollection [

    self subclassResponsibility
]

{ #category : 'initialization' }
HyMergeStrategy >> strategyName [

    self subclassResponsibility
]

{ #category : 'initialization' }
HyMergeStrategy >> tools [

	^ tools

	
]

{ #category : 'initialization' }
HyMergeStrategy >> tools: toolSet [

	tools := toolSet 

	
]

{ #category : 'as yet unclassified' }
HyMergeStrategy >> updateMethod: aMethod withResults: results [

	1 halt.
	"aMethod
		selectedReturnType: selectedType;
		returnTypeConfidence: confidenceValue"
]
