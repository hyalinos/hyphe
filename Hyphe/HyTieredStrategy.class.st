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
    "Core tiered algorithm logic"
    
    "Tier 1: Structural analysis"
    structural ifNotEmpty: [
        ^ Dictionary new
            at: #confidence put: 1.0;
            at: #label put: 'certain';
            at: #reasoning put: 'Provably correct from structure';
            yourself ].
    
    "Tier 2: Single usage observation"
    usage size = 1 ifTrue: [
        ^ Dictionary new
            at: #confidence put: 0.95;
            at: #label put: 'very likely';
            at: #reasoning put: 'Single type observed in usage';
            yourself ].
    
    "Tier 3: Multiple usage observations"
    (usage size between: 2 and: 3) ifTrue: [
        ^ Dictionary new
            at: #confidence put: 0.85;
            at: #label put: 'likely';
            at: #reasoning put: 'Multiple types in usage (bounded polymorphism)';
            yourself ].
    
    usage size > 3 ifTrue: [
        ^ Dictionary new
            at: #confidence put: 0.7;
            at: #label put: 'probable';
            at: #reasoning put: 'Highly polymorphic usage';
            yourself ].
    
    "Tier 4: Usage with name confirmation"
    (usage isNotEmpty and: [ nameHint isNotEmpty ]) ifTrue: [
        | consensus |
        consensus := usage intersection: nameHint.
        
        consensus ifNotEmpty: [
            ^ Dictionary new
                at: #confidence put: 0.9;
                at: #label put: 'very likely';
                at: #reasoning put: 'Usage confirmed by naming';
                yourself ].
        
        ^ Dictionary new
            at: #confidence put: 0.75;
            at: #label put: 'probable';
            at: #reasoning put: 'Usage only (name suggests different)';
            yourself ].
    
    "Tier 5: Name heuristic only"
    nameHint ifNotEmpty: [
        ^ Dictionary new
            at: #confidence put: 0.4;
            at: #label put: 'possible';
            at: #reasoning put: 'Name heuristic only (unreliable)';
            yourself ].
    
    "Tier 6: No information"
    ^ Dictionary new
        at: #confidence put: 0.0;
        at: #label put: 'unknown';
        at: #reasoning put: 'No type information available';
        yourself
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
    usage := grouped at: 'usage' ifAbsent: [ Set new ].
    nameHint := grouped at: 'nameHeuristic' ifAbsent: [ Set new ].
    
    ^ self applyTieredAlgorithm: structural usage: usage nameHint: nameHint
]

{ #category : 'initialization' }
HyTieredStrategy >> strategyName [

    ^ 'Tiered Confidence'
]
