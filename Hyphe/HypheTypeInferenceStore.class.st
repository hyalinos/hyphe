Class {
	#name : 'HypheTypeInferenceStore',
	#superclass : 'Object',
	#instVars : [
		'inferenceData'
	],
	#classVars : [
		'UniqueInstance'
	],
	#category : 'Hyphe-Injection',
	#package : 'Hyphe',
	#tag : 'Injection'
}

{ #category : 'accessing' }
HypheTypeInferenceStore class >> csvPath [
	"Return the path to the CSV file relative to image directory"
	^ FileLocator imageDirectory / 'data' / 'typeToConfidence.csv'
]

{ #category : 'accessing' }
HypheTypeInferenceStore class >> current [
	"Return the singleton instance, creating and loading if needed"
	^ UniqueInstance ifNil: [ UniqueInstance := self new loadFromCSV ]
]

{ #category : 'accessing' }
HypheTypeInferenceStore class >> reload [
<script>
	"Force reload the CSV data"
	self reset.
	^ self current
]

{ #category : 'accessing' }
HypheTypeInferenceStore class >> reset [
	"Clear the singleton to force reload on next access"
	UniqueInstance := nil
]

{ #category : 'testing' }
HypheTypeInferenceStore class >> setForTesting: aStoreInstance [
	"Temporarily set the singleton to a specific instance for testing purposes"
	UniqueInstance := aStoreInstance
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
HypheTypeInferenceStore >> inferenceForClassName: aClassName selector: aSelector [
	"Return {inferredType. confidence} or nil if not found.
	 Lookup strategy:
	   1. Try exact match: ClassName>>selector
	   2. Walk up superclass chain: Superclass>>selector, etc."
	| key result currentClass classObject |
	
	"Try exact match first"
	key := aClassName asString , '>>' , aSelector asString.
	result := inferenceData at: key ifAbsent: [ nil ].
	result ifNotNil: [ ^ result ].
	
	"Try superclass hierarchy lookup"
	classObject := Smalltalk globals at: aClassName asString asSymbol ifAbsent: [ nil ].
	(classObject notNil and: [ classObject isBehavior ]) ifTrue: [
		currentClass := classObject superclass.
		[ currentClass notNil ] whileTrue: [
			key := currentClass name asString , '>>' , aSelector asString.
			result := inferenceData at: key ifAbsent: [ nil ].
			result ifNotNil: [ 
				HypheLogger showCr: '    Using superclass entry: ', currentClass name, '>>', aSelector asString.
				^ result ].
			currentClass := currentClass superclass
		]
	].
	
	"Not found"
	HypheLogger showCr: 'keyNotFound: ', aClassName asString, '>>', aSelector asString.
	^ nil
]

{ #category : 'querying' }
HypheTypeInferenceStore >> inferenceForClassName: aClassName selector: aSelector withFallback: useFallback [
    "Return {inferredType. confidence} or nil if not found.
     Lookup strategy:
       1. Try exact match: ClassName>>selector
       2. Walk up superclass chain: Superclass>>selector, etc.
       3. If useFallback and still not found: try *r>>selector (generic wildcard)"
    | key result currentClass classObject |
    
    "Try exact match first"
    key := aClassName asString , '>>' , aSelector asString.
    result := inferenceData at: key ifAbsent: [ nil ].
    result ifNotNil: [ ^ result ].
    
    "Try superclass hierarchy lookup"
    classObject := Smalltalk globals at: aClassName asString asSymbol ifAbsent: [ nil ].
    (classObject notNil and: [ classObject isBehavior ]) ifTrue: [
        currentClass := classObject superclass.
        [ currentClass notNil ] whileTrue: [
            key := currentClass name asString , '>>' , aSelector asString.
            result := inferenceData at: key ifAbsent: [ nil ].
            result ifNotNil: [ 
                HypheLogger showCr: '    Using superclass entry: ', currentClass name, '>>', aSelector asString.
                ^ result ].
            currentClass := currentClass superclass
        ]
    ].
    
    "If fallback enabled, try generic *r>>selector entry as last resort"
    useFallback ifTrue: [
        key := '*r>>' , aSelector asString.
        result := inferenceData at: key ifAbsent: [ nil ].
        result ifNotNil: [ 
            HypheLogger showCr: '    Using fallback *r entry for selector: ', aSelector asString.
            ^ result ].
    ].
    
    "Not found"
    HypheLogger showCr: '    Key not found: ', aClassName asString, '>>', aSelector asString.
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
	csvFile exists ifFalse: [Transcript showCr: 'Hyphe: typeToConfidence.csv not found.'. ^ self ].
	
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
