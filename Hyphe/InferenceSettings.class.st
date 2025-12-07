Class {
	#name : 'InferenceSettings',
	#superclass : 'Object',
	#classInstVars : [
		'inferenceTools',
		'inferenceConfidence',
		'joinData',
		'subscribedRepositories'
	],
	#category : 'Hyphe-Inference',
	#package : 'Hyphe',
	#tag : 'Inference'
}

{ #category : 'class initialization' }
InferenceSettings class >> defaultConfidence [ 

	^ OrderedCollection new 
		  add: {'0.0'. '0.6'. 'Low'};
		  add: {'0.61'. '0.8'. 'Medium'};
		  add: {'0.81'. '1.0'. 'High'};
		  yourself
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
]

{ #category : 'accessing' }
InferenceSettings class >> joinData [

	^ joinData
]

{ #category : 'class initialization' }
InferenceSettings class >> recalculate [

	| confidenceRanges |
	confidenceRanges := self inferenceConfidence.
	
	joinData := self inferenceTools collect: [ :tool |
		| toolName toolConfidence verbalConfidence |
		toolName := tool at: 1.
		toolConfidence := tool at: 2.
		verbalConfidence := confidenceRanges 
			detect: [ :range | 
				| minValue maxValue |
				minValue := (range at: 1) asNumber.
				maxValue := (range at: 2) asNumber.
				toolConfidence asNumber between: minValue and: maxValue ]
			ifFound: [ :range | range at: 3 ]
			ifNone: [ 'Unknown' ].
		
		{ toolName . toolConfidence . verbalConfidence } ].
	
	^ joinData 
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
