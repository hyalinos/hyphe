"
Class to define a minimum and maximum value for a verbal confidence level, e.g.: (0.0 , 0.5) -> low 
"
Class {
	#name : 'HyConfidenceLevel',
	#superclass : 'Object',
	#instVars : [
		'name',
		'min',
		'max'
	],
	#category : 'Hyphe-Inference',
	#package : 'Hyphe',
	#tag : 'Inference'
}

{ #category : 'accessing' }
HyConfidenceLevel >> max [

	^ max
]

{ #category : 'accessing' }
HyConfidenceLevel >> max: anObject [

	max := anObject
]

{ #category : 'accessing' }
HyConfidenceLevel >> min [

	^ min
]

{ #category : 'accessing' }
HyConfidenceLevel >> min: anObject [

	min := anObject
]

{ #category : 'accessing' }
HyConfidenceLevel >> name [

	^ name
]

{ #category : 'accessing' }
HyConfidenceLevel >> name: anObject [

	name := anObject
]
