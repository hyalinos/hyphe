Class {
	#name : 'HypheTypeInferenceStoreForTesting',
	#superclass : 'HypheTypeInferenceStore',
	#category : 'Hyphe-Tests',
	#package : 'Hyphe-Tests'
}

{ #category : 'initialization' }
HypheTypeInferenceStoreForTesting >> loadFromCSV [
	"Override to provide fixed test data instead of loading from CSV.
	 This creates a predictable test environment independent of CSV files.
	 
	 Class Hierarchy Used in Tests:
	   OrderedCollection -> SequenceableCollection -> Collection -> Object
	   ByteString -> String -> ... -> Object
	 
	 NOTE: Class-side methods use 'ClassName class>>selector' format"
	   
	super initialize.
	
	"Collection superclass methods (instance-side)"
	inferenceData at: 'Collection>>add:' put: {'*r'. 0.9}.
	
	"OrderedCollection specific methods (instance-side)"
	inferenceData at: 'OrderedCollection>>add:' put: {'*t1'. 0.9}.
	inferenceData at: 'Collection>>yourself' put: {'*r'. 1.0}.
	inferenceData at: 'Collection>>size' put: {'Integer'. 1.0}.
	
	"SequenceableCollection methods (instance-side)"
	inferenceData at: 'SequenceableCollection>>first' put: {'*t1'. 0.85}.
	
	"OrderedCollection methods (class and instance)"
	inferenceData at: 'OrderedCollection class>>new' put: {'OrderedCollection'. 1.0}.
	
	"String hierarchy methods (instance-side)"
	inferenceData at: 'String>>asString' put: {'String'. 1.0}.
	inferenceData at: 'String>>,' put: {'String'. 0.95}.
	
	"ByteString methods (instance-side) - ByteString is the actual class of string literals"
	inferenceData at: 'ByteString>>asString' put: {'String'. 1.0}.
	inferenceData at: 'ByteString>>yourself' put: {'*r'. 1.0}.
	
	"Object methods (instance-side - top of instance hierarchy)"
	inferenceData at: 'Object>>yourself' put: {'*r'. 1.0}.
	
	"ProtoObject class methods (class-side - for class>>new lookups)"
	inferenceData at: 'ProtoObject class>>new' put: {'*r'. 0.95}.
	
	"Behavior class methods (class-side - for class>>new lookups)"
	inferenceData at: 'Behavior class>>new' put: {'*r'. 0.95}.
	
	"Wildcard entries (last resort fallback - used when no class/hierarchy matches)"
	inferenceData at: '*r>>new' put: {'*r'. 0.8}.
	inferenceData at: '*r>>doSomething' put: {'Unknown'. 0.3}.
	
	^ self
]
