Class {
	#name : 'HypheNECSymbolEntry',
	#superclass : 'CoSymbolEntry',
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
		HypheLogger show: 'Hyphe error: ', ex messageText; cr.
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
		HypheLogger show: 'Hyphe error: ', ex messageText; cr.
		ex resume ]
]

{ #category : 'as yet unclassified' }
HypheNECSymbolEntry class >> overrideFor: necEntry methodSourceDescription: aClass method: aCompiledMethod [
    "Return completion entry with type inference information.
     Uses resolved receiver type and shows source from actual defining class."
    | styler styledText inferredType confidence labelText color coloredLabel 
      typeStart confidenceStart resolverResult receiverInfo receiverClassName 
      receiverResult receiverClass actualMethod definingClass |

    "Use new resolver with explicit selector from aCompiledMethod"
    HypheLogger showCr: '========================================'.
    HypheLogger showCr: '[Hyphe] Starting type inference for: ', aCompiledMethod selector asString.
    HypheLogger showCr: '========================================'.
    
    resolverResult := HypheASTTypeResolver 
        resolve: necEntry hyNode 
        selector: aCompiledMethod selector 
        depth: 0.
    
    inferredType := resolverResult at: #type.
    confidence := resolverResult at: #confidence.
    
    "Get receiver type from resolver"
    receiverResult := (necEntry hyNode notNil and: [ necEntry hyNode isMessage ])
        ifTrue: [ 
            HypheASTTypeResolver 
                resolve: necEntry hyNode receiver 
                selector: nil 
                depth: 0 ]
        ifFalse: [ 
            Dictionary new 
                at: #type put: 'Unknown'; 
                yourself ].
    
    receiverClassName := receiverResult at: #type ifAbsent: [ 'Unknown' ].
    
    "Look up the actual class and find where method is defined"
    receiverClass := [ Smalltalk globals at: receiverClassName asSymbol ifAbsent: [ nil ] ]
        on: Error do: [ :ex | nil ].
    
    "Find the actual method and its defining class"
    actualMethod := aCompiledMethod.
    definingClass := aClass.
    
    receiverClass ifNotNil: [ 
        (receiverClass respondsTo: #lookupSelector:) ifTrue: [
            | lookedUpMethod |
            lookedUpMethod := receiverClass lookupSelector: aCompiledMethod selector.
            lookedUpMethod ifNotNil: [ 
                actualMethod := lookedUpMethod.
                definingClass := lookedUpMethod methodClass ] ] ].
    
    "NOW create styled text with the CORRECT defining class and method"
    styler := SHRBTextStyler new.
    styler classOrMetaClass: definingClass.
    styledText := styler styledTextFor: (actualMethod sourceCode) asText.
    
    HypheLogger showCr: '[Hyphe] FINAL RESULT:'.
    HypheLogger showCr: '  Expression: ', (resolverResult at: #expression).
    HypheLogger showCr: '  Receiver Type: ', receiverClassName.
    HypheLogger showCr: '  Receiver Class: ', (receiverClass ifNotNil: [ receiverClass name ] ifNil: [ 'nil' ]).
    HypheLogger showCr: '  Defining Class: ', (definingClass ifNotNil: [ definingClass name ] ifNil: [ 'nil' ]).
    HypheLogger showCr: '  Using method from: ', definingClass name.
    HypheLogger showCr: '  Return Type: ', inferredType.
    HypheLogger showCr: '  Confidence: ', confidence printString.
    HypheLogger showCr: '========================================'.
    HypheLogger cr.
    
    "Build label text with proper format"
    receiverInfo := (HypheNECSettings verboseMode) 
        ifTrue: [ 
            String streamContents: [ :s |
                s nextPutAll: receiverClassName.
                
                "Show (DefiningClass) only if method defined in superclass"
                (receiverClass notNil and: [ 
                    definingClass notNil and: [ 
                        receiverClass ~= definingClass ]]) ifTrue: [
                    s
                        space;
                        nextPut: $(;
                        nextPutAll: definingClass name;
                        nextPut: $) ].
                
                s
                    nextPutAll: '>>#';
                    nextPutAll: aCompiledMethod selector asString ] ]
        ifFalse: [ 'method' ].
    
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
        title: definingClass printString
        description: styledText
]

{ #category : 'detail information' }
HypheNECSymbolEntry >> createDescription [
    "Override to always use type inference, even with multiple implementors."
    | resolverResult inferredType targetClass method |
    
    "First try: use type inference to find the specific implementation"
    resolverResult := HypheASTTypeResolver 
        resolve: node 
        selector: self selector 
        depth: 0.
    
    inferredType := resolverResult at: #type ifAbsent: [ nil ].
    
    "If we have an inferred type, try to find the specific method"
    (inferredType notNil and: [ inferredType ~= 'Unknown' ]) ifTrue: [
        targetClass := [ Smalltalk globals at: inferredType asSymbol ifAbsent: [ nil ] ]
            on: Error 
            do: [ :ex | nil ].
        
        (targetClass notNil and: [ targetClass respondsTo: #lookupSelector: ]) ifTrue: [
            method := targetClass lookupSelector: self selector.
            method ifNotNil: [
                "Found specific method for inferred type!"
                ^ self methodSourceDescription: method methodClass method: method
            ]
        ]
    ].
    
    "Fallback: use implementorsDescription with type inference"
    ^ self implementorsDescription: self selector
]

{ #category : 'detail information' }
HypheNECSymbolEntry >> implementorsDescription: aSymbol [
    "Override to use type inference and show colored label even for Unknown.
     Shows implementors list in description field."
    | resolverResult inferredType confidence labelText color coloredLabel 
      typeStart confidenceStart baseLabel implementors output |
    
    HypheLogger showCr: '========================================'.
    HypheLogger showCr: '[Hyphe] Multiple implementors - using type inference for: ', aSymbol asString.
    HypheLogger showCr: '========================================'.
    
    "Use resolver to infer type from the expression"
    resolverResult := HypheASTTypeResolver 
        resolve: node 
        selector: aSymbol 
        depth: 0.
    
    inferredType := resolverResult at: #type.
    confidence := resolverResult at: #confidence.
    
    HypheLogger showCr: '[Hyphe] FINAL RESULT:'.
    HypheLogger showCr: '  Expression: ', (resolverResult at: #expression).
    HypheLogger showCr: '  Type: ', inferredType.
    HypheLogger showCr: '  Confidence: ', confidence printString.
    HypheLogger showCr: '========================================'.
    HypheLogger cr.
    
    "Build label with type and confidence (ALWAYS, even for Unknown)"
    baseLabel := 'method'.
    labelText := baseLabel , ' → ' , inferredType , ' (' , confidence printString , ')'.
    
    "Determine color based on confidence"
    color := HypheNECSettings getColorForConfidence: confidence.
    
    "Calculate positions for color attributes"
    typeStart := baseLabel size + 4.
    confidenceStart := baseLabel size + 4 + inferredType size + 2.
    
    "Create colored text"
    coloredLabel := (labelText , String cr) asText.
    
    "Color the inferred type"
    coloredLabel addAttribute: (TextColor color: color)
        from: typeStart
        to: (typeStart + inferredType size - 1).
    
    "Color the confidence number"
    coloredLabel addAttribute: (TextColor color: color)
        from: confidenceStart
        to: (labelText size - 1).
    
    "If type is Unknown, show implementors in DESCRIPTION"
    (inferredType = 'Unknown' or: [ confidence = 0.0 ]) ifTrue: [
        HypheLogger showCr: '[Hyphe] Type is Unknown - showing implementors in description'.
        output := WriteStream on: String new.
        implementors := self systemNavigation allImplementorsOf: aSymbol.
        implementors isEmpty ifTrue: [
            ^ NECEntryDescription
                label: coloredLabel
                title: '(no implementors)'
                description: 'This is just a symbol.' ].
        implementors do: [ :each |
            output
                nextPutAll: each methodClass printString;
                cr ].
        ^ NECEntryDescription
            label: coloredLabel
            title: '(Implementors)'
            description: output contents
    ].
    
    "Type is known - try to find and show the specific method"
    ^ self showMethodForInferredType: inferredType 
        selector: aSymbol 
        label: coloredLabel
        confidence: confidence
]

{ #category : 'accessing' }
HypheNECSymbolEntry >> label [
    "Return label for the entry. Override to ensure consistency."
    ^ node isMessage
        ifTrue: [ 'method' ]
        ifFalse: [ 'symbol' ]
]

{ #category : 'as yet unclassified' }
HypheNECSymbolEntry >> methodSourceDescription: aClass method: aCompiledMethod [
	^ self class overrideFor: self methodSourceDescription: aClass method: aCompiledMethod
]

{ #category : 'private' }
HypheNECSymbolEntry >> showMethodForInferredType: inferredType selector: aSymbol label: coloredLabel confidence: confidence [
    "Helper to find and display method for the inferred type."
    | targetClass method styledText styler |
    
    targetClass := [ Smalltalk globals at: inferredType asSymbol ifAbsent: [ nil ] ]
        on: Error 
        do: [ :ex | nil ].
    
    (targetClass notNil and: [ targetClass respondsTo: #lookupSelector: ]) ifTrue: [
        method := targetClass lookupSelector: aSymbol.
        method ifNotNil: [
            "Show the actual method source for the inferred type"
            styler := SHRBTextStyler new.
            styler classOrMetaClass: method methodClass.
            styledText := styler styledTextFor: (method sourceCode) asText.
            
            ^ NECEntryDescription
                label: coloredLabel
                title: method methodClass printString , ' (inferred)'
                description: styledText
        ]
    ].
    
    "Fallback: show with inferred type but no source"
    ^ NECEntryDescription
        label: coloredLabel
        title: 'Method: ', aSymbol asString
        description: 'Returns: ', inferredType, ' with confidence ', confidence printString
]
