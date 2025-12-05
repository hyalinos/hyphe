Class {
	#name : 'HypheNECSymbolEntry',
	#superclass : 'NECSymbolEntry',
	#category : 'Hyphe-Injection',
	#package : 'Hyphe',
	#tag : 'Injection'
}

{ #category : 'as yet unclassified' }
HypheNECSymbolEntry class >> overrideFor: necEntry methodSourceDescription: aClass method: aCompiledMethod [
	"I return if it''s a class or a method, its class name, and the implementation.
	 Now uses HypheTypeInferenceStore for type inference data."
	| styler styledText methodName inferredType confidence labelText color coloredLabel typeStart confidenceStart store inferenceResult |
	
	styler := SHRBTextStyler new.
	styler classOrMetaClass: aClass.
	styledText := styler styledTextFor: (aCompiledMethod sourceCode) asText.
	
	"Get method information"
	methodName := aCompiledMethod selector asString.
	Transcript showCr: aClass name.
	"Lookup inference data from store"
	store := HypheTypeInferenceStore current.
	inferenceResult := store inferenceForClass: aClass selector: aCompiledMethod selector.
	
	inferenceResult 
		ifNotNil: [
			inferredType := inferenceResult first.
			confidence := inferenceResult second ]
		ifNil: [
			inferredType := 'Unknown'.
			confidence := 0.0 ].
	
	"Build label text with method name, type, and confidence"
	labelText := methodName , ' -> ' , inferredType , ' (' , confidence printString , ')'.
	
	"Determine color based on confidence"
	color := HypheNECSettings getColorForConfidence: confidence.
	
	"Calculate positions for color attributes"
	typeStart := methodName size + 5.
	confidenceStart := methodName size + 5 + inferredType size + 2.
	
	"Create text and apply colors only to type and confidence"
	coloredLabel := (labelText , String cr) asText.
	
	"Color the inferred type"
	coloredLabel addAttribute: (TextColor color: color)
		from: typeStart
		to: (typeStart + inferredType size - 1).
	
	"Color the confidence number (including parentheses)"
	coloredLabel addAttribute: (TextColor color: color)
		from: confidenceStart
		to: (labelText size - 1).
	
	^ NECEntryDescription
		label: coloredLabel
		title: aClass printString
		description: styledText
]

{ #category : 'as yet unclassified' }
HypheNECSymbolEntry >> methodSourceDescription: aClass method: aCompiledMethod [
	^ self class overrideFor: self methodSourceDescription: aClass method: aCompiledMethod
]
