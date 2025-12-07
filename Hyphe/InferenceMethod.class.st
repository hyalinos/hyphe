"
Stores inference tools names and their default and user-defined confidence numerical scores, e.g. ""Name-based Heuristics"" -> 0.6
"
Class {
	#name : 'InferenceMethod',
	#superclass : 'Object',
	#instVars : [
		'name',
		'confidence'
	],
	#category : 'Hyphe-Data',
	#package : 'Hyphe',
	#tag : 'Data'
}

{ #category : 'accessing' }
InferenceMethod >> confidence [

	^ confidence
]

{ #category : 'accessing' }
InferenceMethod >> confidence: anObject [

	confidence := anObject
]

{ #category : 'accessing' }
InferenceMethod >> name [

	^ name
]

{ #category : 'accessing' }
InferenceMethod >> name: anObject [

	name := anObject
]
