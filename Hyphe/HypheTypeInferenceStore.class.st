Class {
	#name : 'HypheTypeInferenceStore',
	#superclass : 'Object',
	#instVars : [
		'inferenceData'
	],
	#classVars : [
		'UniqueInstance'
	],
	#category : 'Hyphe-Inference',
	#package : 'Hyphe',
	#tag : 'Inference'
}

{ #category : 'accessing' }
HypheTypeInferenceStore class >> csvPath [
	"Return the path to the CSV file relative to image directory"
	^ FileLocator imageDirectory / 'typeToConfidence.csv'
]

{ #category : 'accessing' }
HypheTypeInferenceStore class >> current [
	"Return the singleton instance, creating and loading if needed"
	^ UniqueInstance ifNil: [ UniqueInstance := self new loadFromCSV ]
]

{ #category : 'accessing' }
HypheTypeInferenceStore class >> reload [
	"Force reload the CSV data"
	self reset.
	^ self current
]

{ #category : 'accessing' }
HypheTypeInferenceStore class >> reset [
	"Clear the singleton to force reload on next access"
	UniqueInstance := nil
]

{ #category : 'accessing' }
HypheTypeInferenceStore >> allInferences [
	"Return the raw dictionary for debugging"
	^ inferenceData copy
]

{ #category : 'querying' }
HypheTypeInferenceStore >> confidenceForClass: aClass selector: aSelector [
	"Return the confidence (0-1) or nil"
	| result |
	result := self inferenceForClass: aClass selector: aSelector.
	^ result ifNotNil: [ result second ] ifNil: [ nil ]
]

{ #category : 'querying' }
HypheTypeInferenceStore >> hasInferenceForClass: aClass selector: aSelector [
	"Return true if inference data exists for this method"
	^ (self inferenceForClass: aClass selector: aSelector) notNil
]

{ #category : 'querying' }
HypheTypeInferenceStore >> inferenceForClass: aClass selector: aSelector [
	"Return {inferredType. confidence} or nil if not found.
	 Searches for exact class match first, then walks superclass chain."
	| key result currentClass |
	
	currentClass := aClass.
	[ currentClass notNil ] whileTrue: [
		key := currentClass name asString , '>' , '>' , aSelector asString.
		result := inferenceData at: key ifAbsent: [ nil ].
		result ifNotNil: [ ^ result ].
		currentClass := currentClass superclass
	].
	^ nil
]

{ #category : 'querying' }
HypheTypeInferenceStore >> inferredTypeForClass: aClass selector: aSelector [
	"Return the inferred type string or nil"
	| result |
	result := self inferenceForClass: aClass selector: aSelector.
	^ result ifNotNil: [ result first ] ifNil: [ nil ]
]

{ #category : 'initialization' }
HypheTypeInferenceStore >> initialize [
	super initialize.
	inferenceData := Dictionary new
]

{ #category : 'loading' }
HypheTypeInferenceStore >> loadFromCSV [
	"Load inference data from CSV file. Returns self for chaining."
	| csvFile lines |
	inferenceData := Dictionary new.
	csvFile := self class csvPath.
	csvFile exists ifFalse: [ ^ self ].
	
	lines := csvFile contents lines.
	lines size > 1 ifFalse: [ ^ self ].
	
	"Skip header, process each line"
	(lines allButFirst) do: [ :line |
		| parts methodName className inferredType confidence key |
		parts := line splitOn: $,.
		parts size >= 4 ifTrue: [
			methodName := parts first trimBoth.
			className := parts second trimBoth.
			inferredType := parts third trimBoth.
			confidence := [ parts fourth trimBoth asNumber ] on: Error do: [ 0.5 ].
			
			"Key is className>>methodName for fast lookup"
			key := className , '>' , '>' , methodName.
			inferenceData at: key put: { inferredType. confidence }
		]
	].
	^ self
]

{ #category : 'accessing' }
HypheTypeInferenceStore >> size [
	"Return number of loaded inferences"
	^ inferenceData size
]
