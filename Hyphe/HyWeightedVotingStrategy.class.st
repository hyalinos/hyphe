Class {
	#name : 'HyWeightedVotingStrategy',
	#superclass : 'HyMergeStrategy',
	#instVars : [
		'categoryWeights'
	],
	#category : 'Hyphe-Merge',
	#package : 'Hyphe',
	#tag : 'Merge'
}

{ #category : 'initialization' }
HyWeightedVotingStrategy >> initialize [
    super initialize.
    self initializeWeights
]

{ #category : 'initialization' }
HyWeightedVotingStrategy >> initializeWeights [

    categoryWeights := Dictionary new
        at: 'structural' put: 1.0;
        at: 'usage' put: 0.95;
        at: 'static' put: 0.75;
        at: 'nameHeuristic' put: 0.4;
        at: 'llm' put: 0.6;
        at: 'unknown' put: 0.5;
        yourself
]

{ #category : 'initialization' }
HyWeightedVotingStrategy >> labelForConfidence: conf [
    conf >= 0.95 ifTrue: [ ^ 'certain' ].
    conf >= 0.85 ifTrue: [ ^ 'very likely' ].
    conf >= 0.7 ifTrue: [ ^ 'likely' ].
    conf >= 0.5 ifTrue: [ ^ 'probable' ].
    conf >= 0.3 ifTrue: [ ^ 'possible' ].
    ^ 'uncertain'
]

{ #category : 'initialization' }
HyWeightedVotingStrategy >> mergeTypes: typesCollection [
    | votes totalWeight maxVote winnerTypes confidence |
      
	typesCollection ifEmpty: [
        ^ Dictionary new
            at: #confidence put: 0.0;
            at: #label put: 'unknown';
            at: #reasoning put: 'No types available';
            yourself ].
    
    votes := Dictionary new.
    totalWeight := 0.
    
    "Collect votes"
    typesCollection do: [ :hyType |
        | category weight typeStr |
        category := self categoryForSource: hyType source.
        weight := categoryWeights at: category ifAbsent: [ 0.5 ].
        typeStr := hyType name.
        
        votes at: typeStr put: (votes at: typeStr ifAbsent: [ 0 ]) + weight.
        totalWeight := totalWeight + weight ].
    
    "Find winner(s)"
    maxVote := votes values max.
    winnerTypes := votes keys select: [ :type | (votes at: type) = maxVote ].
    confidence := maxVote / totalWeight.
    
    ^ Dictionary new
        at: #confidence put: confidence;
        at: #label put: (self labelForConfidence: confidence);
        at: #reasoning put: 'Weighted voting across ', typesCollection size asString, ' sources';
        yourself
]

{ #category : 'initialization' }
HyWeightedVotingStrategy >> setWeight: weight forCategory: category [

    categoryWeights at: category put: weight
]

{ #category : 'initialization' }
HyWeightedVotingStrategy >> strategyName [

    ^ 'Weighted Voting'
]
