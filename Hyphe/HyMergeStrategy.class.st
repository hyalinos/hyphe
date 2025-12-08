Class {
	#name : 'HyMergeStrategy',
	#superclass : 'Object',
	#instVars : [
		'mergeResults'
	],
	#category : 'Hyphe-Merge',
	#package : 'Hyphe',
	#tag : 'Merge'
}

{ #category : 'initialization' }
HyMergeStrategy >> confidenceLevelFor: confidenceValue [ 
	
	^ InferenceSettings resolveConfidenceLevel: confidenceValue.	
	
]

{ #category : 'initialization' }
HyMergeStrategy >> createMergeResult: selectedType
confidence: confidenceValue
confidenceLevel: levelString
agreingSources: sourcesList
reasoning: reasoningString
forMethod: methodName
inClass: className
inPackage: packageName
inRepository: repositoryName [ 

^ Dictionary new
at: #repositoryName put: repositoryName;
at: #packageName put: packageName;
at: #className put: className;
at: #methodName put: methodName;
at: #type put: selectedType;
at: #confidence put: confidenceValue;
at: #confidenceLevel put: levelString;
at: #agreingSources put: sourcesList;
at: #reasoning put: reasoningString;
yourself
]

{ #category : 'initialization' }
HyMergeStrategy >> findAgreeingSourcesFor: selectedType in: typesCollection [ 

	^ (typesCollection select: [ :hyType | hyType name = selectedType ]) collect: [ :hyType | hyType source ]
]

{ #category : 'initialization' }
HyMergeStrategy >> groupTypesByCategory: typesCollection [
    "Group HyType objects by their source category"

    | grouped |
    grouped := Dictionary new.
    
    typesCollection do: [ :hyType |
        | category typeStr |
        category := self categoryForSource: hyType source.
        typeStr := hyType name.
        
        grouped 
            at: category 
            ifAbsentPut: [ Set new ].
        (grouped at: category) add: typeStr ].
    
    ^ grouped
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
HyMergeStrategy >> mergeTypes: typesCollection forMethod: methodName inClass: className inPackage: packageName inRepository: repositoryName [

	self subclassResponsibility
]

{ #category : 'initialization' }
HyMergeStrategy >> strategyName [
    "Return name of this strategy for reporting"

    self subclassResponsibility
]

{ #category : 'as yet unclassified' }
HyMergeStrategy >> updateMethod: aMethod withType: selectedType confidence: confidenceValue [

	aMethod
		selectedType: selectedType
		returnTypeConfidence: confidenceValue
]
