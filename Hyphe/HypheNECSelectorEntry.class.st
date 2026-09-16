Class {
	#name : 'HypheNECSelectorEntry',
	#superclass : 'CoSelectorEntry',
	#category : 'Hyphe-Injection',
	#package : 'Hyphe',
	#tag : 'Injection'
}

{ #category : 'detail information' }
HypheNECSelectorEntry >> createDescription [
    "Override to always use type inference, even with multiple implementors."
    | resolverResult inferredType targetClass method |
    
    "Use type inference to find the specific implementation"
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
HypheNECSelectorEntry >> implementorsDescription: aSymbol [
    "Override to use type inference and show colored label even for Unknown.
     Shows implementors list in description field."
    | resolverResult inferredType confidence labelText color coloredLabel 
      typeStart confidenceStart baseLabel targetClass method styledText styler
      implementors output |
    
    HypheLogger showCr: '========================================'.
    HypheLogger showCr: '[Hyphe] SelectorEntry - Multiple implementors inference for: ', aSymbol asString.
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

{ #category : 'accessing' }
HypheNECSelectorEntry >> label [
    "Return label for the entry with type inference."
    node isMessage ifFalse: [ ^ '' ].
    ^ 'method'
]

{ #category : 'private' }
HypheNECSelectorEntry >> methodSourceDescription: aClass method: aCompiledMethod [
	^ HypheNECSymbolEntry overrideFor: self methodSourceDescription: aClass method: aCompiledMethod
]
