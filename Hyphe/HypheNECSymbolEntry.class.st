Class {
	#name : 'HypheNECSymbolEntry',
	#superclass : 'NECSymbolEntry',
	#category : 'Hyphe-Injection',
	#package : 'Hyphe',
	#tag : 'Injection'
}

{ #category : 'as yet unclassified' }
HypheNECSymbolEntry class >> getOriginInfoString: aNode class: aClass selector: selector [
	| receiverClass |
	^ [
		receiverClass := aNode
			ifNil: [ 'Unknown receiver' ]
			ifNotNil: [
				aNode isMessage
					ifTrue: [
						(aNode receiver propertyAt: #type ifAbsent: [ 'Unknown class' ]) asString
					]
					ifFalse: [ 'Not a message' ] ].
		String streamContents: [ :s |
			s
				nextPutAll: receiverClass;
				space;
				nextPut: $(;
				nextPutAll: (aClass ifNil: [ 'Unknown class' ]) name;
				nextPut: $);
				nextPutAll: '>>#';
				nextPutAll: (selector ifNil: [ 'nil' ]) asString ]
	] on: Exception do: [ :ex |
		Transcript show: 'Hyphe error: ', ex messageText; cr.
		ex resume ]
]

{ #category : 'as yet unclassified' }
HypheNECSymbolEntry class >> getReceiverClassName: aNode [
	| receiverClass |
	^ [
		receiverClass := aNode
			ifNil: [ 'Unknown receiver' ]
			ifNotNil: [
				aNode isMessage
					ifTrue: [
						(aNode receiver propertyAt: #type ifAbsent: [ 'Unknown class' ]) asString
					]
					ifFalse: [ 'Not a message' ] ].
		^ receiverClass 
	] on: Exception do: [ :ex |
		Transcript show: 'Hyphe error: ', ex messageText; cr.
		ex resume ]
]

{ #category : 'as yet unclassified' }
HypheNECSymbolEntry class >> overrideFor: necEntry methodSourceDescription: aClass method: aCompiledMethod [
	"I return if it''s a class or a method, its class name, and the implementation.
	 Now uses HypheTypeInferenceStore for type inference data."
	| styler styledText inferredType confidence labelText color coloredLabel typeStart confidenceStart store inferenceResult receiverInfo|

	styler := SHRBTextStyler new.
	styler classOrMetaClass: aClass.
	styledText := styler styledTextFor: (aCompiledMethod sourceCode) asText.
	
	"Get method information"
	receiverInfo:= (HypheNECSettings verboseMode) ifTrue:[self getOriginInfoString: necEntry hyNode class: aClass selector: aCompiledMethod selector] ifFalse:['method']. 
	
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
	labelText := receiverInfo , ' → ' , inferredType , ' (' , confidence printString , ')'.
	
	"Determine color based on confidence"
	color := HypheNECSettings getColorForConfidence: confidence.
	
	"Calculate positions for color attributes"
	typeStart := receiverInfo size + 4.
	confidenceStart := receiverInfo size + 4 + inferredType size + 2.
	
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
