"
I am like the consensus strategy but if there is a ground truth source I take its value and do not continue analysis
"
Class {
	#name : 'HyBiasedConsensusStrategy',
	#superclass : 'HyConsensusStrategy',
	#category : 'Hyphe-Merge',
	#package : 'Hyphe',
	#tag : 'Merge'
}

{ #category : 'as yet unclassified' }
HyBiasedConsensusStrategy class >> prettyName [ 

	^ 'Biased Consensus Strategy'
]

{ #category : 'initialization' }
HyBiasedConsensusStrategy >> mergeTypes: typesCollection [
    "Require consensus among sources but if confident type is present resturn it"

	| confidentTypes |
	
	confidentTypes := self checkForConfidentType: typesCollection.
	confidentTypes ifNotEmpty: [
		|hyType|
		hyType := confidentTypes first.
		^ Dictionary new
        at: #types put: (OrderedCollection new add: (hyType name); yourself);
        at: #confidence put: (self extractToolConfidence: (hyType));
        at: #sources put: (OrderedCollection new add: #TypeMeConfident; yourself);
        yourself	
		 ].

	^ super mergeTypes: typesCollection.

]

{ #category : 'initialization' }
HyBiasedConsensusStrategy >> strategyName [

    ^ 'Biased Consensus'
]
