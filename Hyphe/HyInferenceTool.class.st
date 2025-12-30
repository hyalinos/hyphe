"
Local representation of an inference tool that stores its name, class, confidence score and corresponding (to image settings) verbal level, e.g ""AST-based inference, 1, high""
"
Class {
	#name : 'HyInferenceTool',
	#superclass : 'Object',
	#instVars : [
		'name',
		'clazz',
		'defaultConfidence',
		'confidence',
		'level'
	],
	#category : 'Hyphe-Inference',
	#package : 'Hyphe',
	#tag : 'Inference'
}

{ #category : 'accessing' }
HyInferenceTool >> clazz [

	^ clazz
]

{ #category : 'accessing' }
HyInferenceTool >> clazz: aClass [ 
	clazz := aClass
]

{ #category : 'accessing' }
HyInferenceTool >> confidence [

	^ confidence
]

{ #category : 'accessing' }
HyInferenceTool >> confidence: anObject [

	confidence := anObject
]

{ #category : 'accessing' }
HyInferenceTool >> defaultConfidence [

	^ defaultConfidence
]

{ #category : 'accessing' }
HyInferenceTool >> defaultConfidence: anObject [

	defaultConfidence := anObject
]

{ #category : 'accessing' }
HyInferenceTool >> level [

	^ level
]

{ #category : 'accessing' }
HyInferenceTool >> level: anObject [

	level := anObject
]

{ #category : 'accessing' }
HyInferenceTool >> name [

	^ name
]

{ #category : 'accessing' }
HyInferenceTool >> name: aString [ 
	name := aString
]
