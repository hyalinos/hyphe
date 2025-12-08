Class {
	#name : 'HyTypeMerger',
	#superclass : 'Object',
	#instVars : [
		'strategy',
		'hyData',
		'results'
	],
	#category : 'Hyphe-Merge',
	#package : 'Hyphe',
	#tag : 'Merge'
}

{ #category : 'instance creation' }
HyTypeMerger class >> new [
    ^ self newWithStrategy: HyTieredStrategy new

]

{ #category : 'instance creation' }
HyTypeMerger class >> newWithStrategy: aStrategy [

    ^ super new
        strategy: aStrategy;
        yourself
]

{ #category : 'as yet unclassified' }
HyTypeMerger >> buildReturnTypeInfo: aHyMethod [
    "Build return type information dictionary"
    | types uniqueTypes sources confidence label |
    
    types := aHyMethod returnTypes.
    
    types ifEmpty: [
        ^ Dictionary new
            at: #types put: #();
            at: #confidence put: 0.0;
            at: #label put: 'unknown';
            at: #sources put: #();
            at: #reasoning put: 'No return type information';
            yourself ].
    
    uniqueTypes := (types collect: [ :t | t name ]) asSet asArray.
    sources := (types collect: [ :t | t source ]) asSet asArray.
    confidence := aHyMethod confidence.
    
    "Determine label from confidence"
    label := self labelForConfidence: confidence.
    
    ^ Dictionary new
        at: #types put: uniqueTypes;
        at: #confidence put: confidence;
        at: #label put: label;
        at: #sources put: sources;
        at: #reasoning put: (self reasoningForMethod: aHyMethod);
        yourself
]

{ #category : 'as yet unclassified' }
HyTypeMerger >> collectStatistics [
    "Collect aggregation statistics"
    ^ self collectStatistics: hyData
]

{ #category : 'as yet unclassified' }
HyTypeMerger >> collectStatistics: aHyDataRepresentation [
    "Collect aggregation statistics"
    | stats |
    stats := Dictionary new
        at: 'strategy' put: strategy strategyName;
        at: 'totalMethods' put: 0;
        at: 'certain' put: 0;
        at: 'veryLikely' put: 0;
        at: 'likely' put: 0;
        at: 'probable' put: 0;
        at: 'possible' put: 0;
        at: 'unknown' put: 0;
        yourself.
    
    aHyDataRepresentation packages do: [ :package |
        package classes do: [ :class |
            #(instSide classSide) do: [ :side |
                (class perform: side) methods do: [ :method |
                    | conf |
                    stats at: 'totalMethods' put: (stats at: 'totalMethods') + 1.
                    conf := method confidence.
                    
                    conf >= 0.95 ifTrue: [ stats at: 'certain' put: (stats at: 'certain') + 1 ].
                    (conf between: 0.85 and: 0.94) ifTrue: [ stats at: 'veryLikely' put: (stats at: 'veryLikely') + 1 ].
                    (conf between: 0.7 and: 0.84) ifTrue: [ stats at: 'likely' put: (stats at: 'likely') + 1 ].
                    (conf between: 0.5 and: 0.69) ifTrue: [ stats at: 'probable' put: (stats at: 'probable') + 1 ].
                    (conf between: 0.3 and: 0.49) ifTrue: [ stats at: 'possible' put: (stats at: 'possible') + 1 ].
                    conf < 0.3 ifTrue: [ stats at: 'unknown' put: (stats at: 'unknown') + 1 ] ] ] ] ].
    
    ^ stats
]

{ #category : 'as yet unclassified' }
HyTypeMerger >> findMethodReturnType: methodName inClass: className package: packageName [
    "Find method and return its type information
    Returns Dictionary with: #types, #confidence, #label, #sources or nil if not found"
    | package class method |
    
    package := hyData packages 
        detect: [ :p | p name = packageName ]
        ifNone: [ ^ nil ].
    
    class := package classes 
        detect: [ :c | c name = className ]
        ifNone: [ ^ nil ].
    
    method := class  methods 
        detect: [ :m | m name = methodName ]
        ifNone: [ 
           ^ nil ].
    
    ^ self buildReturnTypeInfo: method
]

{ #category : 'accessing' }
HyTypeMerger >> hyData [

	^ hyData
]

{ #category : 'accessing' }
HyTypeMerger >> hyData: anObject [

	hyData := anObject
]

{ #category : 'as yet unclassified' }
HyTypeMerger >> initialize [

	results := OrderedCollection new
]

{ #category : 'as yet unclassified' }
HyTypeMerger >> labelForConfidence: conf [
    conf >= 0.95 ifTrue: [ ^ 'certain' ].
    conf >= 0.85 ifTrue: [ ^ 'very likely' ].
    conf >= 0.7 ifTrue: [ ^ 'likely' ].
    conf >= 0.5 ifTrue: [ ^ 'probable' ].
    conf >= 0.3 ifTrue: [ ^ 'possible' ].
    ^ 'uncertain'

]

{ #category : 'as yet unclassified' }
HyTypeMerger >> mergeForObject: anObject withTypes: typesCollection [


	typesCollection ifEmpty: [
			anObject confidence: 0.0.
			^ self ].

	^ strategy new mergeTypes: typesCollection
]

{ #category : 'as yet unclassified' }
HyTypeMerger >> mergeHyTypes: aHyDataRepresentation [

	hyData := aHyDataRepresentation.

	hyData packages do: [ :package |
			package classes do: [ :class | " class variables do: [ :variable |
        			self mergeForObject: variable withTypes: variable types ]."
					class methods do: [ :method |
						self mergeMethodTypes: method class: class package: package ] ] ]
]

{ #category : 'as yet unclassified' }
HyTypeMerger >> mergeMethodTypes: aHyMethod [
 
    aHyMethod returnTypes ifNotEmpty: [
        self mergeForObject: aHyMethod withTypes: aHyMethod returnTypes ].
    
    "aHyMethod parameters do: [ :param |
        self mergeForObject: param withTypes: param types ]"
]

{ #category : 'as yet unclassified' }
HyTypeMerger >> mergeMethodTypes: aMethod class: aClass package: aPackage [

	| result |
	result := aMethod returnTypes ifNotEmpty: [
		          self
			          mergeForObject: aMethod
			          withTypes: aMethod returnTypes ].

	aMethod
		returnTypeConfidence: (result at: #confidence);
		selectedReturnType: (result at: #types).

	results add: (Dictionary new
			 at: #packageName put: aPackage name;
			 at: #className put: aClass name;
			 at: #methodName put: aMethod name;
			 at: #type put: (result at: #types);
			 at: #confidence put: (result at: #confidence);
			 at: #level
			 put:
				 (InferenceSettings resolveConfidenceLevel:
						  (result at: #confidence));
			 at: #sources put: (result at: #sources);
			 at: #reasoning put: (result at: #reasoning);
			 yourself).


	"aHyMethod parameters do: [ :param |
        self mergeForObject: param withTypes: param types ]"
]

{ #category : 'as yet unclassified' }
HyTypeMerger >> printStatistics [
    "Print statistics for current hyData"
    self printStatistics: (self collectStatistics)
]

{ #category : 'as yet unclassified' }
HyTypeMerger >> printStatistics: stats [
    "Print statistics nicely"
    | total |
    total := stats at: 'totalMethods'.
    
    Transcript cr; show: '=== Aggregation Statistics ==='; cr.
    Transcript show: 'Strategy: ', (stats at: 'strategy'); cr.
    Transcript show: 'Total methods: ', total asString; cr.
    total = 0 ifTrue: [ ^ self ].
    
    Transcript show: 'Certain (≥95%): ', (stats at: 'certain') asString, 
        ' (', ((stats at: 'certain') / total * 100) rounded asString, '%)'; cr.
    Transcript show: 'Very likely (85-94%): ', (stats at: 'veryLikely') asString,
        ' (', ((stats at: 'veryLikely') / total * 100) rounded asString, '%)'; cr.
    Transcript show: 'Likely (70-84%): ', (stats at: 'likely') asString,
        ' (', ((stats at: 'likely') / total * 100) rounded asString, '%)'; cr.
    Transcript show: 'Probable (50-69%): ', (stats at: 'probable') asString,
        ' (', ((stats at: 'probable') / total * 100) rounded asString, '%)'; cr.
    Transcript show: 'Possible (30-49%): ', (stats at: 'possible') asString,
        ' (', ((stats at: 'possible') / total * 100) rounded asString, '%)'; cr.
    Transcript show: 'Unknown (<30%): ', (stats at: 'unknown') asString,
        ' (', ((stats at: 'unknown') / total * 100) rounded asString, '%)'; cr

]

{ #category : 'as yet unclassified' }
HyTypeMerger >> reasoningForMethod: aHyMethod [
    "Get reasoning for this method's confidence"
    | result |
    result := strategy mergeTypes: aHyMethod returnTypes.
    ^ result at: #reasoning ifAbsent: [ 'No reasoning available' ]
]

{ #category : 'accessing' }
HyTypeMerger >> results [

	^ results 
]

{ #category : 'accessing' }
HyTypeMerger >> strategy [

	^ strategy
]

{ #category : 'accessing' }
HyTypeMerger >> strategy: anObject [

	strategy := anObject
]
