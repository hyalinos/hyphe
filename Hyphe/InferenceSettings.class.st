Class {
	#name : 'InferenceSettings',
	#superclass : 'Object',
	#classInstVars : [
		'inferenceTools',
		'inferenceConfidence'
	],
	#category : 'Hyphe-Inference',
	#package : 'Hyphe',
	#tag : 'Inference'
}

{ #category : 'class initialization' }
InferenceSettings class >> defaultConfidence [ 

	^ OrderedCollection new 
		  add: ('0.0', '0.6', 'Low');
		  add: ('0.61', '0.8', 'Medium');
		  add: ('0.81', '1.0', 'High');
		  yourself
]

{ #category : 'class initialization' }
InferenceSettings class >> defaultTools [ 

	^ Dictionary new
		at: 'AST-based inference' put: 1.0;
		at: 'Type Info Tools' put: 0.75;
		at: 'Name-based Heuristics' put: 0.5;
		at: 'Offline Test Profiling' put: 0.5;
		yourself
]

{ #category : 'accessing' }
InferenceSettings class >> inferenceConfidence [

	^ inferenceConfidence
]

{ #category : 'accessing' }
InferenceSettings class >> inferenceTools [

	^ inferenceTools
]

{ #category : 'class initialization' }
InferenceSettings class >> initialize [ 

	inferenceConfidence := self defaultConfidence.
	inferenceTools := self defaultTools.
]
