Class {
	#name : 'HyTieredStrategy',
	#superclass : 'HyMergeStrategy',
	#category : 'Hyphe-Merge',
	#package : 'Hyphe',
	#tag : 'Merge'
}

{ #category : 'as yet unclassified' }
HyTieredStrategy class >> prettyName [

	^ 'Tiered Strategy'
]

{ #category : 'initialization' }
HyTieredStrategy >> applyTieredAlgorithm: structural usage: usage nameHint: nameHint [
      
	"Tier 1: Structural analysis"
    structural ifNotEmpty: [
        ^ Dictionary new
            at: #confidence put: 1.0;
            at: #types put: (structural collect: [:t | t name]) asOrderedCollection;
            at: #reasoning put: 'Provably correct from structure';
				at: #sources put: (structural collect: [:t | t source]) asOrderedCollection ;
            yourself ].
    
    "Tier 2: Single usage observation"
    usage size = 1 ifTrue: [
        ^ Dictionary new
            at: #confidence put: 0.75;
            at: #types put: (usage collect: [:t | t name]) asOrderedCollection;
            at: #reasoning put: 'Single type observed in usage';
				at: #sources put: (usage collect: [:t | t source]) asOrderedCollection ;
            yourself ].
    
    "Tier 3: Multiple usage observations"
    (usage size between: 2 and: 3) ifTrue: [
        ^ Dictionary new
            at: #confidence put: 0.6;
            at: #types put: (usage collect: [:t | t name]) asOrderedCollection;
            at: #reasoning put: 'Multiple types in usage (bounded polymorphism)';
			   at: #sources put: (usage collect: [:t | t source]) asOrderedCollection ;
            yourself ].
    
    usage size > 3 ifTrue: [
        ^ Dictionary new
            at: #confidence put: 0.4;
            at: #types put: (usage collect: [:t | t name]) asOrderedCollection;
            at: #reasoning put: 'Highly polymorphic usage';
				at: #sources put: (usage collect: [:t | t source]) asOrderedCollection ;
            yourself ].
    
    "Tier 4: Usage with name confirmation"
    (usage isNotEmpty and: [ nameHint isNotEmpty ]) ifTrue: [
        | consensus |
        consensus := usage intersection: nameHint.
        
        consensus ifNotEmpty: [
			|names namesInBoth merged|
			names := (usage collect: [:t | t name]).
			namesInBoth := nameHint collect: [:t | names includes: t name  ].
			merged := (((usage collect: [:t | t source]) asOrderedCollection) addAll: (nameHint collect: [:t | t source])) yourself.  
            ^ Dictionary new
                at: #confidence put: 0.7;
                at: #types put: namesInBoth asOrderedCollection;
                at: #reasoning put: 'Usage confirmed by naming';
				    at: #sources put: merged ;
                yourself ]. 
		].
    
    "Tier 5: Name heuristic only"
    nameHint ifNotEmpty: [
        ^ Dictionary new
            at: #confidence put: 0.5;
            at: #types put: (nameHint collect: [:t | t name]) asOrderedCollection;
            at: #reasoning put: 'Name heuristic only (unreliable)';
				at: #sources put: (nameHint collect: [:t | t source]) asOrderedCollection ;
            yourself ].
    
    "Tier 6: No information"
    ^ Dictionary new
        at: #confidence put: 0.0;
        at: #types put: OrderedCollection new;
		  at: #sources put: OrderedCollection new ;
        at: #reasoning put: 'No type information available';
        yourself
]

{ #category : 'as yet unclassified' }
HyTieredStrategy >> categoryForSource: source [

	| className|
	
	className := tools select: [ :o | o name = source ].
	className ifNotEmpty: [ ^ className first tier ].
	
	^ (InferenceSettings toolNameToClass at: source) tier.   
    
]

{ #category : 'as yet unclassified' }
HyTieredStrategy >> groupTypesByCategory: typesCollection [ 
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
        (grouped at: category) add: hyType ].
    
    ^ grouped

]

{ #category : 'initialization' }
HyTieredStrategy >> mergeTypes: typesCollection [
    "Apply tiered confidence algorithm"

    | grouped structural usage nameHint |
    
    typesCollection ifEmpty: [
        ^ Dictionary new
            at: #confidence put: 0.0;
            at: #label put: 'unknown';
            at: #reasoning put: 'No types available';
            yourself ].
    
    grouped := self groupTypesByCategory: typesCollection.
    structural := grouped at: 'structural' ifAbsent: [ Set new ].
    usage := grouped at: 'observation' ifAbsent: [ Set new ].
    nameHint := grouped at: 'heuristic' ifAbsent: [ Set new ].
    
    ^ self applyTieredAlgorithm: structural usage: usage nameHint: nameHint
]

{ #category : 'initialization' }
HyTieredStrategy >> strategyName [

    ^ 'Tiered Confidence'
]
