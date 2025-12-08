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
		'mergeStrategies'
	],
	#category : 'Hyphe-Inference',
	#package : 'Hyphe',
	#tag : 'Inference'
}

{ #category : 'class initialization' }
InferenceSettings class >> defaultConfidence [ 

	^ Dictionary new 
		  at: 'Low' put: #(0.0 0.6);
		  at: 'Medium' put: #(0.61  0.8);
		  at: 'High' put: #(0.81 1.0);
		  yourself
]

{ #category : 'class initialization' }
InferenceSettings class >> defaultMergeStrategy [ 

	^ defaultMergeStrategy
]

{ #category : 'class initialization' }
InferenceSettings class >> defaultTools [ 

	^ OrderedCollection new
		add: {'AST-based inference' . '1.0'};
		add: {'Type Info Tools'. '0.75'};
		add: {'Name-based Heuristics'. '0.5'};
		add: {'Offline Test Profiling'. '0.5'};
		yourself
]

{ #category : 'accessing' }
InferenceSettings class >> inferenceConfidence [

	^ inferenceConfidence
]

{ #category : 'as yet unclassified' }
InferenceSettings class >> inferenceConfidence: aConfidence [

	inferenceConfidence := aConfidence 
]

{ #category : 'accessing' }
InferenceSettings class >> inferenceTools [

	^ inferenceTools
]

{ #category : 'accessing' }
InferenceSettings class >> inferenceTools: data [

	inferenceTools := data
]

{ #category : 'class initialization' }
InferenceSettings class >> initialize [ 

	inferenceConfidence := self defaultConfidence.
	inferenceTools := self defaultTools.
	self recalculate.
	subscribedRepositories := OrderedCollection new.
	toolNameToClass := Dictionary new at: 'AST-based inference' put: TypeMeConfident;
		at: 'Type Info Tools' put: TITMethodReturnTypesGatherer;
		at: 'Name-based Heuristics' put: TypeMeNameBased; 
		yourself. 
		"at: 'Offline Test Profiling' put ."
	defaultMergeStrategy := HyWeightedVotingStrategy.
	mergeStrategies := Set withAll: {HyWeightedVotingStrategy . HyTieredStrategy . HyConsensusStrategy}.
		
]

{ #category : 'accessing' }
InferenceSettings class >> joinData [

	^ joinData
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

{ #category : 'class initialization' }
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

{ #category : 'accessing' }
InferenceSettings class >> toolNameToClass [

	^ toolNameToClass 
		
]
