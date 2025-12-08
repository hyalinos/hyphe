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

{ #category : 'initialization' }
HyConsensusStrategy >> initialize [

    super initialize.
    minimumSources := 2
]

{ #category : 'initialization' }
HyConsensusStrategy >> labelForConfidence: conf [

    conf >= 0.9 ifTrue: [ ^ 'certain' ].
    conf >= 0.7 ifTrue: [ ^ 'likely' ].
    conf >= 0.5 ifTrue: [ ^ 'probable' ].
    ^ 'uncertain'
]

{ #category : 'initialization' }
HyConsensusStrategy >> mergeTypes: typesCollection [
    "Require consensus among sources"

    | typeCounts maxCount consensusTypes confidence |
    
    typesCollection ifEmpty: [
        ^ Dictionary new
            at: #confidence put: 0.0;
            at: #label put: 'unknown';
            at: #reasoning put: 'No types available';
            yourself ].
    
    "Count how many sources agree on each type"
    typeCounts := Dictionary new.
    typesCollection do: [ :hyType |
        | typeStr |
        typeStr := hyType type.
        typeCounts at: typeStr put: (typeCounts at: typeStr ifAbsent: [ 0 ]) + 1 ].
    
    maxCount := typeCounts values max.
    consensusTypes := typeCounts keys select: [ :type | 
        (typeCounts at: type) >= minimumSources ].
    
    "Calculate confidence based on consensus"
    consensusTypes ifEmpty: [
        confidence := 0.3 ]
    ifNotEmpty: [
        confidence := (maxCount / typesCollection size) * 0.9 + 0.1 ].
    
    ^ Dictionary new
        at: #confidence put: confidence;
        at: #label put: (self labelForConfidence: confidence);
        at: #reasoning put: maxCount asString, ' sources agree';
        yourself
]

{ #category : 'initialization' }
HyConsensusStrategy >> minimumSources: anInteger [

    minimumSources := anInteger
]

{ #category : 'initialization' }
HyConsensusStrategy >> strategyName [

    ^ 'Consensus'
]
