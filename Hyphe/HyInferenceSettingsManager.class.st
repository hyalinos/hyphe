Class {
	#name : 'HyInferenceSettingsManager',
	#superclass : 'Object',
	#classInstVars : [
		'user'
	],
	#category : 'Hyphe-Inference',
	#package : 'Hyphe',
	#tag : 'Inference'
}

{ #category : 'initialization' }
HyInferenceSettingsManager class >> initialize [ 

	self initializeDefaultValues.
	self initializeUserSettings
]

{ #category : 'initialization' }
HyInferenceSettingsManager class >> initializeDefaultValues [

	self subclassResponsibility 
]

{ #category : 'initialization' }
HyInferenceSettingsManager class >> initializeUserSettings [

	user := self new
]

{ #category : 'initialization' }
HyInferenceSettingsManager class >> reset [ 
	
	self initializeUserSettings
]

{ #category : 'accessing' }
HyInferenceSettingsManager class >> user [

	^ user
]
