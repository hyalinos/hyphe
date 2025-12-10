Class {
	#name : 'HyWeightedVotingStrategy',
	#superclass : 'HyMergeStrategy',
	#category : 'Hyphe-Merge',
	#package : 'Hyphe',
	#tag : 'Merge'
}

{ #category : 'as yet unclassified' }
HyWeightedVotingStrategy class >> prettyName [

	^ 'Weighted Voting Strategy'
]

{ #category : 'initialization' }
HyWeightedVotingStrategy >> initialize [

	super initialize.
]

{ #category : 'initialization' }
HyWeightedVotingStrategy >> mergeTypes: typesCollection [

	| votes totalWeight maxVote winnerTypes confidence sources |
	typesCollection ifEmpty: [
			^ Dictionary new
				  at: #confidence put: 0.0;
				  at: #label put: 'Unknown';
				  at: #reasoning put: 'No types available';
				  at: #sources put: 'No information' yourself ].

	votes := Dictionary new.
	sources := Set new.
	totalWeight := 0.

	"Collect votes"
	typesCollection do: [ :hyType |
			| weight typeStr source |
			typeStr := hyType name.

			source := InferenceSettings inferenceTools select: [ :a |
				          a first = hyType source ].
			source
				ifEmpty: [
						InferenceSettings toolNameToClass keysAndValuesDo: [ :tool :aClass |
								hyType source = aClass name ifTrue: [
										weight := (InferenceSettings inferenceTools select: [ :a |
											           a first = tool ]) first last asNumber ] ] ]
				ifNotEmpty: [ weight := source first last asNumber ].


			votes at: typeStr put: (votes at: typeStr ifAbsent: [ 0 ]) + weight.
			totalWeight := totalWeight + weight ].

	"Find winner(s)"
	maxVote := votes values max.

	winnerTypes := votes keys select: [ :type |
		               (votes at: type) = maxVote ].
	
	typesCollection collect: [:t | (winnerTypes includes: t name) ifTrue: [ sources add: t source ] ].
	confidence := maxVote / totalWeight.


	^ Dictionary new
		  at: #confidence put: confidence;
		  at: #types put: winnerTypes;
		  at: #reasoning
		  put:
			  'Weighted voting across ' , typesCollection size asString
			  , ' sources';
		  at: #sources put: sources;
		  yourself
]

{ #category : 'initialization' }
HyWeightedVotingStrategy >> strategyName [

    ^ 'Weighted Voting'
]
