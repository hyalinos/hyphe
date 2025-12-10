Class {
	#name : 'HyConsensusStrategy',
	#superclass : 'HyMergeStrategy',
	#instVars : [
		'minimumSources'
	],
	#category : 'Hyphe-Merge',
	#package : 'Hyphe',
	#tag : 'Merge'
}

{ #category : 'as yet unclassified' }
HyConsensusStrategy class >> prettyName [ 

	^ 'Consensus Strategy'
]

{ #category : 'as yet unclassified' }
HyConsensusStrategy >> applyNoisyOR: confidences [
    "Apply noisy-OR formula to combine multiple confidence values.
    Formula: 1 - ∏(1 - ci) for all confidence values ci
    This represents independent evidence sources.
    Returns Float in [0,1]"
    
    | product result |
    
    "Handle empty case"
    confidences ifEmpty: [ ^ 0.0 ].
    
    "Calculate product of (1 - confidence) for all confidences"
    product := 1.0.
    confidences do: [ :conf |
        product := product * (1.0 - conf).
    ].
    
    "Apply noisy-OR: 1 - product"
    result := 1.0 - product.
    
    "Ensure result stays in [0,1] range (safety check)"
    result := result max: 0.0.
    result := result min: 1.0.
    
    ^ result
]

{ #category : 'as yet unclassified' }
HyConsensusStrategy >> calculateAgreementFactor: voteCount totalTools: totalToolCount [    
    | factor |
     
	totalToolCount = 0 ifTrue: [ ^ 0.0 ].
    factor := voteCount asFloat / totalToolCount asFloat.
    factor := factor max: 0.0.
    factor := factor min: 1.0.
    
    ^ factor
]

{ #category : 'as yet unclassified' }
HyConsensusStrategy >> countVotesForTypes: groupedByType [
    
    | voteCounts |
    voteCounts := Dictionary new.
	
    groupedByType keysAndValuesDo: [ :typeName :hyTypes |     
		voteCounts at: typeName put: hyTypes size.
    ].
    
    ^ voteCounts
]

{ #category : 'as yet unclassified' }
HyConsensusStrategy >> extractSourceNames: hyTypes [
    "Extract the list of tool names that contributed to this type.
    Returns OrderedCollection of Strings"
    
    ^ hyTypes collect: [ :hyType | hyType source ]
]

{ #category : 'as yet unclassified' }
HyConsensusStrategy >> getSourcesForType: typeName inCollection: typesCollection [
    
    | sources |
    sources := OrderedCollection new.
    
    typesCollection do: [ :hyType |
        hyType name = typeName ifTrue: [
            sources add: hyType source.
        ].
    ].
    
    ^ sources
]

{ #category : 'as yet unclassified' }
HyConsensusStrategy >> groupTypesByName: typesCollection [
    
    | grouped |
    grouped := Dictionary new.
    
    typesCollection do: [ :hyType |
        | typeName |
        typeName := hyType name.
        grouped at: typeName ifAbsentPut: [ OrderedCollection new ].
        (grouped at: typeName) add: hyType.
    ].
    
    ^ grouped
	
]

{ #category : 'initialization' }
HyConsensusStrategy >> initialize [

    super initialize.
    minimumSources := 2.
	 self getToolConfidenceMap.
]

{ #category : 'initialization' }
HyConsensusStrategy >> mergeTypes: typesCollection [
    "Require consensus among sources"

	| groupedByType votingResults bestType mergedConfidence agreementFactor finalConfidence toolConfidences sources |
	
	groupedByType := self groupTypesByName: typesCollection.  
   votingResults := self countVotesForTypes: groupedByType.
	bestType := self selectBestTypeFrom: votingResults.
	bestType ifNil: [ ^ nil ].
	toolConfidences := self extractToolConfidences: (groupedByType at: bestType).
	mergedConfidence := self applyNoisyOR: toolConfidences.
	agreementFactor := self calculateAgreementFactor: 
        (votingResults at: bestType) 
        totalTools: self tools size.
   finalConfidence := mergedConfidence * agreementFactor.

	sources := self getSourcesForType: bestType inCollection: typesCollection.

	^ Dictionary new
        at: #types put: (OrderedCollection new add: bestType; yourself);
        at: #confidence put: finalConfidence;
        at: #baseConfidence put: mergedConfidence;
        at: #agreementFactor put: agreementFactor;
        at: #votes put: (votingResults at: bestType);
        at: #totalTools put: self tools size;
        at: #sources put: sources;
        yourself

]

{ #category : 'initialization' }
HyConsensusStrategy >> minimumSources: anInteger [

    minimumSources := anInteger
]

{ #category : 'as yet unclassified' }
HyConsensusStrategy >> selectBestTypeFrom: votingResults [
 
    | maxVotes bestType |
    
   votingResults ifEmpty: [ ^ nil ].
    
    maxVotes := 0.
    bestType := nil.
    
    votingResults keysAndValuesDo: [ :typeName :voteCount |
        voteCount > maxVotes ifTrue: [
            maxVotes := voteCount.
            bestType := typeName.
        ].
    ].
    
    ^ bestType
]

{ #category : 'initialization' }
HyConsensusStrategy >> strategyName [

    ^ 'Consensus'
]
