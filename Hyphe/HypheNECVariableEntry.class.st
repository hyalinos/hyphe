Class {
	#name : 'HypheNECVariableEntry',
	#superclass : 'CoVariableEntry',
	#category : 'Hyphe-Injection',
	#package : 'Hyphe',
	#tag : 'Injection'
}

{ #category : 'detail information' }
HypheNECVariableEntry >> createDescription [
    "Create description with type inference for variables.
     Uses node type property if available, otherwise falls back to standard behavior."
    | clazz resolverResult inferredType confidence labelText color coloredLabel 
      typeStart confidenceStart baseLabel |
    
    "Try to get the class from contents"
    clazz := self class environment at: contents ifAbsent: [ nil ].
    
    "Try to infer type from node if it's a message completion"
    (node notNil and: [ node isMessage ]) ifTrue: [
        HypheLogger showCr: '========================================'.
        HypheLogger showCr: '[Hyphe] Variable entry type inference for: ', contents.
        HypheLogger showCr: '========================================'.
        
        resolverResult := HypheASTTypeResolver resolve: node selector: nil depth: 0.
        inferredType := resolverResult at: #type.
        confidence := resolverResult at: #confidence.
        
        HypheLogger showCr: '[Hyphe] FINAL RESULT:'.
        HypheLogger showCr: '  Variable: ', contents.
        HypheLogger showCr: '  Type: ', inferredType.
        HypheLogger showCr: '  Confidence: ', confidence printString.
        HypheLogger showCr: '========================================'.
        HypheLogger cr.
        
        "Build label with type and confidence"
        baseLabel := self label.
        labelText := baseLabel , ' → ', inferredType , ' (' , confidence printString , ')'.
        
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
        
        ^ NECEntryDescription
            label: coloredLabel
            title: (clazz ifNotNil: [ clazz printString ] ifNil: [ inferredType ])
            description: (clazz ifNotNil: [ clazz comment ] ifNil: [ 'Inferred type: ', inferredType ])
    ].
    
    "Fall back to standard behavior for non-message nodes"
    ^ clazz
        ifNil: [ NECEntryDescription label: self label ]
        ifNotNil: [
            clazz isClass
                ifFalse: [
                    "Handle few globals correctly"
                    NECEntryDescription label: self label ]
                ifTrue: [
                    NECEntryDescription
                        label: self label
                        title: clazz printString
                        description: clazz comment ] ]
]
