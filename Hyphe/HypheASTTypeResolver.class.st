Class {
	#name : 'HypheASTTypeResolver',
	#superclass : 'Object',
	#instVars : [
		'store'
	],
	#category : 'Hyphe-Injection',
	#package : 'Hyphe',
	#tag : 'Injection'
}

{ #category : 'resolving' }
HypheASTTypeResolver class >> resolve: aNode depth: aDepth [
    "Main entry point for type resolution with depth tracking"
    ^ self new
        initialize;
        resolveNode: aNode depth: aDepth
]

{ #category : 'resolving' }
HypheASTTypeResolver class >> resolve: aNode selector: aSelector depth: aDepth [
    "Main entry point with explicit selector override.
     Used in autocompletion where node may be incomplete but selector is known."
    ^ self new
        initialize;
        resolveNode: aNode selector: aSelector depth: aDepth
]

{ #category : 'private' }
HypheASTTypeResolver >> extractParameterIndex: aTypeString [
    "Extract the parameter index from a parametric type string.
     E.g., '*t1' returns 1, '*t2' returns 2, etc."
    | indexString |
    indexString := aTypeString allButFirst: 2.
    ^ [ indexString asInteger ] on: Error do: [ 0 ]
]

{ #category : 'initialization' }
HypheASTTypeResolver >> initialize [
    "Initialize the resolver with the type inference store"
    super initialize.
    store := HypheTypeInferenceStore current
]

{ #category : 'private' }
HypheASTTypeResolver >> isParametricType: aTypeString [
    "Check if a type string represents a parametric type (e.g., *t1, *t2).
     Parametric types reference the type of method arguments."
    ^ aTypeString notNil 
        and: [ aTypeString isString 
        and: [ aTypeString size >= 3 
        and: [ (aTypeString beginsWith: '*t') 
        and: [ (aTypeString allButFirst: 2) allSatisfy: [ :c | c isDigit ] ] ] ] ]
]

{ #category : 'resolving' }
HypheASTTypeResolver >> resolveLiteralNode: aNode depth: aDepth [
    "Resolve a literal node (number, string, symbol, boolean, nil, etc.)"
    | indent expression literalValue typeName |
    
    indent := String new: (aDepth * 2) withAll: $ .
    expression := self safeExpressionFor: aNode.
    
    "Get the literal value"
    literalValue := [ aNode value ] on: Error do: [ nil ].
    
    "Determine the type based on the literal value"
    literalValue ifNil: [
        typeName := 'UndefinedObject'.
    ] ifNotNil: [
        typeName := literalValue class name asString.
    ].
    
    HypheLogger showCr: indent, '[Hyphe] Resolving literal: ', expression, 
        ' -> ', typeName, ' (confidence: 1.0)'.
    
    ^ Dictionary new
        at: #type put: typeName;
        at: #confidence put: 1.0;
        at: #expression put: expression;
        yourself
]

{ #category : 'resolving' }
HypheASTTypeResolver >> resolveMessageNode: aNode depth: aDepth [
    "Resolve a message send node by first resolving the receiver, 
     then looking up the method return type. Handles parametric types."
    | receiverResult receiverType receiverConfidence selector methodResult 
      finalType finalConfidence indent expression methodConfidence parametricResult |
    
    indent := String new: (aDepth * 2) withAll: $ .
    selector := aNode selector.
    expression := self safeExpressionFor: aNode.
    
    HypheLogger showCr: indent, '[Hyphe] Resolving message: ', expression.
    
    "Step 1: Resolve the receiver type recursively"
    receiverResult := self resolveNode: aNode receiver depth: (aDepth + 1).
    receiverType := receiverResult at: #type.
    receiverConfidence := receiverResult at: #confidence.
    
    HypheLogger showCr: indent, '  Receiver resolved: ', receiverType, 
        ' (confidence: ', receiverConfidence printString, ')'.
    
    "Step 2: Look up method return type in store WITH FALLBACK to wildcards"
    methodResult := store inferenceForClassName: receiverType selector: selector withFallback: true.
    
    methodResult ifNotNil: [
        finalType := methodResult first.
        methodConfidence := methodResult second.
        
        HypheLogger showCr: indent, '  Method lookup: ', receiverType, '>>', selector asString.
        HypheLogger showCr: indent, '    Returns: ', finalType, 
            ' (method confidence: ', methodConfidence printString, ')'.
        
        "Step 3: Check if return type is parametric (e.g., *t1, *t2) or receiver (*r)"
        (finalType = '*r') ifTrue: [
            "Return type is the receiver type"
            HypheLogger showCr: indent, '    Receiver type (*r) detected: returns ', receiverType.
            finalConfidence := receiverConfidence * methodConfidence.
            
            HypheLogger showCr: indent, '    Composed confidence: ', 
                receiverConfidence printString, ' * ', methodConfidence printString, 
                ' = ', finalConfidence printString.
            
            finalType := receiverType.
        ] ifFalse: [
            (self isParametricType: finalType) ifTrue: [
                "Parametric type referencing an argument"
                parametricResult := self resolveParametricType: finalType forMessage: aNode depth: aDepth.
                finalType := parametricResult at: #type.
                "Compose all confidences: receiver * method * argument"
                finalConfidence := receiverConfidence * methodConfidence * (parametricResult at: #confidence).
                
                HypheLogger showCr: indent, '    Final composed confidence: ', 
                    receiverConfidence printString, ' * ', methodConfidence printString, 
                    ' * ', (parametricResult at: #confidence) printString, 
                    ' = ', finalConfidence printString.
            ] ifFalse: [
                "Non-parametric type: compose receiver and method confidences"
                finalConfidence := receiverConfidence * methodConfidence.
                
                HypheLogger showCr: indent, '    Composed confidence: ', 
                    receiverConfidence printString, ' * ', methodConfidence printString, 
                    ' = ', finalConfidence printString.
            ]
        ].
        
        ^ Dictionary new
            at: #type put: finalType;
            at: #confidence put: finalConfidence;
            at: #expression put: expression;
            yourself
    ] ifNil: [
        "Method not found in store"
        finalType := 'Unknown'.
        finalConfidence := 0.0.
        
        HypheLogger showCr: indent, '  Method lookup: ', receiverType, '>>', selector asString.
        HypheLogger showCr: indent, '    NOT FOUND in store'.
        
        ^ Dictionary new
            at: #type put: finalType;
            at: #confidence put: finalConfidence;
            at: #expression put: expression;
            yourself
    ]
]

{ #category : 'resolving' }
HypheASTTypeResolver >> resolveMessageNode: aNode selector: aSelectorOrNil depth: aDepth [
    "Resolve a message send node by first resolving the receiver, 
     then looking up the method return type. Handles parametric types and *r.
     If aSelectorOrNil is provided, use it instead of node selector."
    | receiverResult receiverType receiverConfidence selector methodResult 
      finalType finalConfidence indent expression methodConfidence parametricResult |
    
    indent := String new: (aDepth * 2) withAll: $ .
    selector := aSelectorOrNil ifNil: [ aNode selector ].
    expression := self safeExpressionFor: aNode.
    
    HypheLogger showCr: indent, '[Hyphe] Resolving message: ', expression.
    
    "Step 1: Resolve the receiver type recursively"
    receiverResult := self resolveNode: aNode receiver selector: nil depth: (aDepth + 1).
    receiverType := receiverResult at: #type.
    receiverConfidence := receiverResult at: #confidence.
    
    HypheLogger showCr: indent, '  Receiver resolved: ', receiverType, 
        ' (confidence: ', receiverConfidence printString, ')'.
    
    "Step 2: Look up method return type in store (with fallback to *r)"
    methodResult := store inferenceForClassName: receiverType selector: selector withFallback: true.
    
    methodResult ifNotNil: [
        finalType := methodResult first.
        methodConfidence := methodResult second.
        
        HypheLogger showCr: indent, '  Method lookup: ', receiverType, '>>', selector asString.
        HypheLogger showCr: indent, '    Returns: ', finalType, 
            ' (method confidence: ', methodConfidence printString, ')'.
        
        "Step 3: Check if return type is parametric (e.g., *t1, *t2) or receiver (*r)"
        (finalType = '*r') ifTrue: [
            "Return type is the receiver type"
            HypheLogger showCr: indent, '    Receiver type (*r) detected: returns ', receiverType.
            finalConfidence := receiverConfidence * methodConfidence.
            
            HypheLogger showCr: indent, '    Composed confidence: ', 
                receiverConfidence printString, ' * ', methodConfidence printString, 
                ' = ', finalConfidence printString.
            
            finalType := receiverType.
        ] ifFalse: [
            (self isParametricType: finalType) ifTrue: [
                "Parametric type referencing an argument"
                parametricResult := self resolveParametricType: finalType forMessage: aNode depth: aDepth.
                finalType := parametricResult at: #type.
                "Compose all confidences: receiver * method * argument"
                finalConfidence := receiverConfidence * methodConfidence * (parametricResult at: #confidence).
                
                HypheLogger showCr: indent, '    Final composed confidence: ', 
                    receiverConfidence printString, ' * ', methodConfidence printString, 
                    ' * ', (parametricResult at: #confidence) printString, 
                    ' = ', finalConfidence printString.
            ] ifFalse: [
                "Non-parametric type: compose receiver and method confidences"
                finalConfidence := receiverConfidence * methodConfidence.
                
                HypheLogger showCr: indent, '    Composed confidence: ', 
                    receiverConfidence printString, ' * ', methodConfidence printString, 
                    ' = ', finalConfidence printString.
            ]
        ].
        
        ^ Dictionary new
            at: #type put: finalType;
            at: #confidence put: finalConfidence;
            at: #expression put: expression;
            yourself
    ] ifNil: [
        "Method not found in store"
        finalType := 'Unknown'.
        finalConfidence := 0.0.
        
        HypheLogger showCr: indent, '  Method lookup: ', receiverType, '>>', selector asString.
        HypheLogger showCr: indent, '    NOT FOUND in store'.
        
        ^ Dictionary new
            at: #type put: finalType;
            at: #confidence put: finalConfidence;
            at: #expression put: expression;
            yourself
    ]
]

{ #category : 'resolving' }
HypheASTTypeResolver >> resolveNode: aNode depth: aDepth [
    "Recursively resolve type and confidence for a node.
     Returns a Dictionary with #type, #confidence, #expression keys.
     depth tracks nesting level for Transcript indentation."
    ^ self resolveNode: aNode selector: nil depth: aDepth
]

{ #category : 'resolving' }
HypheASTTypeResolver >> resolveNode: aNode selector: aSelectorOrNil depth: aDepth [
    "Recursively resolve type and confidence for a node.
     If aSelectorOrNil is provided, use it instead of node selector (for autocompletion).
     Returns a Dictionary with #type, #confidence, #expression keys.
     depth tracks nesting level for Transcript indentation."
    | indent |
    
    indent := String new: (aDepth * 2) withAll: $ .
    
    aNode ifNil: [
        HypheLogger showCr: indent, '[Hyphe] Node is nil - Unknown'.
        ^ Dictionary new
            at: #type put: 'Unknown';
            at: #confidence put: 0.0;
            at: #expression put: 'nil';
            yourself ].
    
    "Check if it's a message node (method call)"
    (aNode isKindOf: OCMessageNode) ifTrue: [
        ^ self resolveMessageNode: aNode selector: aSelectorOrNil depth: aDepth ].
    
    "Check if it's a variable node"
    (aNode isKindOf: OCVariableNode) ifTrue: [
        ^ self resolveVariableNode: aNode depth: aDepth ].
    
    "Check if it's a literal node (numbers, strings, symbols, booleans, nil)"
    (aNode isKindOf: OCLiteralNode) ifTrue: [
        ^ self resolveLiteralNode: aNode depth: aDepth ].
    
    "Check if it has a #type property (already annotated)"
    [ | typeProperty |
        typeProperty := aNode propertyAt: #type ifAbsent: [ nil ].
        typeProperty ifNotNil: [
            HypheLogger showCr: indent, '[Hyphe] Found annotated type: ', typeProperty asString.
            ^ Dictionary new
                at: #type put: typeProperty asString;
                at: #confidence put: 1.0;
                at: #expression put: aNode formattedCode;
                yourself ]
    ] on: Error do: [ :ex | "Ignore errors accessing properties" ].
    
    "Default: Unknown type"
    HypheLogger showCr: indent, '[Hyphe] Unknown node type: ', aNode class name.
    ^ Dictionary new
        at: #type put: 'Unknown';
        at: #confidence put: 0.0;
        at: #expression put: (self safeExpressionFor: aNode);
        yourself
]

{ #category : 'resolving' }
HypheASTTypeResolver >> resolveParametricType: parametricType forMessage: aMessageNode depth: aDepth [
    "Resolve a parametric type by finding the actual type of the referenced argument.
     E.g., if parametricType is '*t1', resolve the type of the first argument.
     Returns a Dictionary with #type and #confidence."
    | paramIndex arguments argNode argResult indent |
    
    indent := String new: (aDepth * 2) withAll: $ .
    paramIndex := self extractParameterIndex: parametricType.
    arguments := aMessageNode arguments.
    
    HypheLogger showCr: indent, '    Parametric type detected: ', parametricType.
    HypheLogger showCr: indent, '    Resolving argument ', paramIndex printString, ' type...'.
    
    "Validate parameter index"
    (paramIndex < 1 or: [ paramIndex > arguments size ]) ifTrue: [
        HypheLogger showCr: indent, '    ERROR: Invalid parameter index ', paramIndex printString, 
            ' (method has ', arguments size printString, ' arguments)'.
        ^ Dictionary new
            at: #type put: 'Unknown';
            at: #confidence put: 0.0;
            yourself
    ].
    
    "Resolve the argument type"
    argNode := arguments at: paramIndex.
    argResult := self resolveNode: argNode selector: nil depth: (aDepth + 1).
    
    HypheLogger showCr: indent, '    Argument ', paramIndex printString, ' resolved to: ', 
        (argResult at: #type), ' (confidence: ', (argResult at: #confidence) printString, ')'.
    
    ^ argResult
]

{ #category : 'resolving' }
HypheASTTypeResolver >> resolveVariableNode: aNode depth: aDepth [
    "Resolve a variable node by checking its annotated type property.
     If the variable is a class reference (uppercase), resolve it as ClassName class"
    | indent typeProperty expression varName classObject |
    
    indent := String new: (aDepth * 2) withAll: $ .
    expression := self safeExpressionFor: aNode.
    
    HypheLogger showCr: indent, '[Hyphe] Resolving variable: ', expression.
    
    "Try to get the type property"
    [ typeProperty := aNode propertyAt: #type ifAbsent: [ nil ].
    ] on: Error do: [ :ex | typeProperty := nil ].
    
    typeProperty ifNotNil: [
        HypheLogger showCr: indent, '  Type: ', typeProperty asString, ' (confidence: 1.0)'.
        ^ Dictionary new
            at: #type put: typeProperty asString;
            at: #confidence put: 1.0;
            at: #expression put: expression;
            yourself
    ].
    
    "Check if variable is a class reference (starts with uppercase)"
    varName := expression trimBoth.
    (varName notEmpty and: [ varName first isUppercase ]) ifTrue: [
        classObject := Smalltalk globals at: varName asSymbol ifAbsent: [ nil ].
        (classObject notNil and: [ classObject isBehavior ]) ifTrue: [
            "It's a class reference - type is 'ClassName class'"
            HypheLogger showCr: indent, '  Type: ', varName, ' class (confidence: 1.0) [class reference]'.
            ^ Dictionary new
                at: #type put: varName, ' class';
                at: #confidence put: 1.0;
                at: #expression put: expression;
                yourself
        ]
    ].
    
    "Default: Unknown type"
    HypheLogger showCr: indent, '  Type: Unknown (confidence: 0.0)'.
    ^ Dictionary new
        at: #type put: 'Unknown';
        at: #confidence put: 0.0;
        at: #expression put: expression;
        yourself
]

{ #category : 'private' }
HypheASTTypeResolver >> safeExpressionFor: aNode [
    "Safely get the source code expression for a node"
    ^ [ aNode formattedCode ] 
        on: Error 
        do: [ :ex | 
            [ aNode sourceCode ] 
                on: Error 
                do: [ :ex2 | '<expression>' ] ]
]
