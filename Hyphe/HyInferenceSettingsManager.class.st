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
]

{ #category : 'initialization' }
HyInferenceSettingsManager class >> initializeDefaultValues [

	self subclasses do: [ :subclass | 
		subclass initializeDefaultValues.
		subclass initializeUser 
	]
]

{ #category : 'initialization' }
HyInferenceSettingsManager class >> initializeUser [

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
