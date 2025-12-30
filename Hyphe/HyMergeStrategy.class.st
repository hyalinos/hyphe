Class {
	#name : 'HyMergeStrategy',
	#superclass : 'Object',
	#instVars : [
		'mergeResults',
		'tools',
		'toolConfidenceMap'
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

{ #category : 'initialization' }
HyMergeStrategy >> confidenceLevelFor: confidenceValue [ 
	
	^ InferenceSettings resolveConfidenceLevel: confidenceValue.	
	
]

{ #category : 'as yet unclassified' }
HyMergeStrategy >> extractToolConfidence: hyType [
     
   ^ toolConfidenceMap at: (hyType source) ifAbsent: [ 0.5 ].
    
]

{ #category : 'as yet unclassified' }
HyMergeStrategy >> extractToolConfidences: hyTypes [
      
    ^ hyTypes collect: [ :hyType | self extractToolConfidence: hyType].
   
]

{ #category : 'initialization' }
HyMergeStrategy >> findAgreeingSourcesFor: selectedType in: typesCollection [ 

	^ (typesCollection select: [ :hyType | hyType name = selectedType ]) collect: [ :hyType | hyType source ]
]

{ #category : 'as yet unclassified' }
HyMergeStrategy >> getToolConfidenceMap [
   "map tool className confidence"
    
    | mapping |
    mapping := Dictionary new.
    
    InferenceSettings user inferenceTools do: [ :pair |
        | toolName confidenceString confidenceFloat |

        toolName := (InferenceSettings toolNameToClass at: (pair first)) name.
        confidenceString := pair second.
        confidenceFloat := confidenceString asNumber.
        mapping at: toolName put: confidenceFloat.
    ].
    
    toolConfidenceMap := mapping
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

{ #category : 'accessing' }
HyMergeStrategy >> toolConfidenceMap [

	^ toolConfidenceMap
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
