"
This class stores all information related to inference settings:

	- Tools inference confidence
	- Confidence range
	- Tools display names to class names
	- Repositories subscribed for analysis
"
Class {
	#name : 'InferenceSettings',
	#superclass : 'Object',
	#classInstVars : [
		'inferenceTools',
		'inferenceConfidence',
		'joinData',
		'subscribedRepositories',
		'toolNameToClass',
		'defaultMergeStrategy',
		'mergeStrategies',
		'mergeStrategy'
	],
	#category : 'Hyphe-Inference',
	#package : 'Hyphe',
	#tag : 'Inference'
}

{ #category : 'confidence' }
InferenceSettings class >> defaultConfidence [ 

	^ Dictionary new 
		  at: 'Low' put: #(0.0 0.6);
		  at: 'Medium' put: #(0.61  0.8);
		  at: 'High' put: #(0.81 1.0);
		  yourself
]

{ #category : 'mergeStrategies' }
InferenceSettings class >> defaultMergeStrategy [

	^ HyWeightedVotingStrategy
]

{ #category : 'tools' }
InferenceSettings class >> defaultTools [ 

	^ OrderedCollection new
		add: {'AST-based inference' . '1.0'};
		add: {'Type Info Tools'. '0.75'};
		add: {'Name-based Heuristics'. '0.5'};
		add: {'Offline Test Profiling'. '0.5'};
		yourself
]

{ #category : 'mergeStrategies' }
InferenceSettings class >> getStrategyByName: aStrategy [

	|className prettyName|
	className := self mergeStrategies select: [ :o | o name = aStrategy ].
	className ifNotEmpty: [ ^ className first ].
	prettyName := self mergeStrategies select: [ :o |
		              o prettyName = aStrategy ].
	prettyName ifNotEmpty: [ ^ prettyName first ]
]

{ #category : 'confidence' }
InferenceSettings class >> inferenceConfidence [

	^ inferenceConfidence
]

{ #category : 'confidence' }
InferenceSettings class >> inferenceConfidence: aConfidence [

	inferenceConfidence := aConfidence 
]

{ #category : 'tools' }
InferenceSettings class >> inferenceTools [

	^ inferenceTools
]

{ #category : 'tools' }
InferenceSettings class >> inferenceTools: data [

	inferenceTools := data
]

{ #category : 'class initialization' }
InferenceSettings class >> initialize [

	inferenceConfidence := self defaultConfidence.
	inferenceTools := self defaultTools.
	mergeStrategy := defaultMergeStrategy.
	self recalculate.
	
	subscribedRepositories := OrderedCollection new.
	toolNameToClass := Dictionary new
		                   at: 'AST-based inference' put: TypeMeConfident;
		                   at: 'Type Info Tools'
		                   put: TITMethodReturnTypesGatherer;
		                   at: 'Name-based Heuristics' put: TypeMeNameBased;
		                   yourself.
	"at: 'Offline Test Profiling' put ."
]

{ #category : 'accessing' }
InferenceSettings class >> joinData [

	^ joinData
]

{ #category : 'mergeStrategies' }
InferenceSettings class >> mergeStrategies [

	^ { HyConsensusStrategy . HyTieredStrategy . HyWeightedVotingStrategy }
]

{ #category : 'mergeStrategies' }
InferenceSettings class >> mergeStrategy [

	^ mergeStrategy
]

{ #category : 'mergeStrategies' }
InferenceSettings class >> mergeStrategy: anObject [

	| className prettyName|
	
	(self mergeStrategies includes: anObject) ifTrue: [ mergeStrategy := anObject ].
	className := self mergeStrategies select: [:o | o name = anObject ].
	className ifNotEmpty: [ mergeStrategy := className first ].
	prettyName := self mergeStrategies select: [:o | o prettyName = anObject ].
	prettyName ifNotEmpty: [ mergeStrategy := prettyName first ].
	 
]

{ #category : 'class initialization' }
InferenceSettings class >> recalculate [
	
	joinData := self inferenceTools collect: [ :tool |
		| toolName toolConfidence verbalConfidence |
		toolName := tool at: 1.
		toolConfidence := tool at: 2.
		
		verbalConfidence := self resolveConfidenceLevel: toolConfidence. 
		
		{ toolName . toolConfidence . verbalConfidence } 
	].
	
	^ joinData 
]

{ #category : 'confidence' }
InferenceSettings class >> resolveConfidenceLevel: toolConfidence [ 

	self inferenceConfidence keysAndValuesDo:[:level :range |
		| minValue maxValue |
		
		minValue := (range first) asNumber.
		maxValue := (range last) asNumber.
		(toolConfidence asNumber between: minValue and: maxValue) ifTrue: [ ^ level ]
	].
		
	^ 'Unknown'.	
	
	
]

{ #category : 'class initialization' }
InferenceSettings class >> restoreDefault [ 

	self initialize
]

{ #category : 'class initialization' }
InferenceSettings class >> restoreDefaultConfidenceAndTools [ 

	inferenceConfidence := self defaultConfidence.
	inferenceTools := self defaultTools.
	self recalculate.
]

{ #category : 'accessing' }
InferenceSettings class >> subscribedRepositories [

	^ subscribedRepositories
]

{ #category : 'accessing' }
InferenceSettings class >> subscribedRepositories: aCollection [

	subscribedRepositories := aCollection 
]

{ #category : 'tools' }
InferenceSettings class >> toolNameToClass [

	^ toolNameToClass 
		
]
