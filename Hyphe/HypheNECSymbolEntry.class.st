Class {
	#name : 'HypheNECSymbolEntry',
	#superclass : 'NECSymbolEntry',
	#category : 'Hyphe-Injection',
	#package : 'Hyphe',
	#tag : 'Injection'
}

{ #category : 'as yet unclassified' }
HypheNECSymbolEntry >> methodSourceDescription: aClass method: aCompiledMethod [
	"I return if it's a class or a method, its class name, and the implementation."
	| styler styledText methodName inferredType confidence labelText color coloredLabel typeStart confidenceStart |
	
	styler := SHRBTextStyler new.
	styler classOrMetaClass: aClass.
	styledText := styler styledTextFor: (aCompiledMethod sourceCode) asText.
	
	"Get method information"
	methodName := aCompiledMethod selector asString.
	inferredType := 'InferredType'.
	confidence := 0.75.
	
	"Build label text with method name, type, and confidence"
	labelText := methodName , ' - ' , inferredType , ' (' , confidence printString , ')'.
	
	"Determine color based on confidence"
	color := confidence >= 0.81
		ifTrue: [ Color green ]
		ifFalse: [ confidence >= 0.61
			ifTrue: [ Color yellow ]
			ifFalse: [ Color orange ] ].
	
	"Calculate positions for color attributes"
	"typeStart: after 'methodName - ' (methodName size + 3)"
	typeStart := methodName size + 4.
	"confidenceStart: after 'methodName - InferredType (' (methodName size + 4 + inferredType size + 2)"
	confidenceStart := methodName size + 4 + inferredType size + 2.
	
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
