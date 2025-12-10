Class {
	#name : 'HyBiasedWeightedVotingStrategy',
	#superclass : 'HyWeightedVotingStrategy',
	#category : 'Hyphe-Merge',
	#package : 'Hyphe',
	#tag : 'Merge'
}

{ #category : 'initialization' }
HyBiasedWeightedVotingStrategy >> mergeTypes: typesCollection [
    "Like weighted voting strategy but if confident type is present resturn it"

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
HyBiasedWeightedVotingStrategy >> strategyName [

    ^ 'Biased Weighted Voting'
]
