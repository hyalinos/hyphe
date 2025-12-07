Class {
	#name : 'TypeMeResultsExporter',
	#superclass : 'InferenceResultsExporter',
	#category : 'Hyphe-Export',
	#package : 'Hyphe',
	#tag : 'Export'
}

{ #category : 'initialization' }
TypeMeResultsExporter >> doExport [

	(self groupTypeResults: source) keysAndValuesDo: [
		:packageName
		:classesDict |
		self processPackage: packageName classes: classesDict ]
]

{ #category : 'initialization' }
TypeMeResultsExporter >> groupTypeResults: typeResults [
    "Group type results by package -> class -> method -> types"
    | grouped |
    grouped := Dictionary new.
    
    typeResults do: [ :result |
        | packageName className methodName typeName packageDict classDict methodSet |
        packageName := result at: 1.
        className := result at: 2.
        methodName := result at: 3.
        typeName := result at: 4.
        
        "Get or create package entry"
        packageDict := grouped at: packageName ifAbsentPut: [ Dictionary new ].
        
        "Get or create class entry"
        classDict := packageDict at: className ifAbsentPut: [ Dictionary new ].
        
        "Get or create method entry (set of types)"
        methodSet := classDict at: methodName ifAbsentPut: [ Set new ].
        
        "Add type to set"
        methodSet add: typeName ].
    
    ^ grouped
]

{ #category : 'initialization' }
TypeMeResultsExporter >> processClass: className inPackage: package methods: methodsDict [
	"Process a class and its methods"

	| class |
	class := self findOrCreateClass: className inPackage: package.
	methodsDict keysAndValuesDo: [ :methodName :typeSet |
		self processMethod: methodName withTypes: typeSet inClass: class ]
]

{ #category : 'initialization' }
TypeMeResultsExporter >> processMethod: methodName withTypes: typeSet inClass: aClass [
	"Process a method and add return types"

	| method |
	method := aClass findOrCreateMethod: methodName.
	self addReturnTypes: typeSet toMethod: method
	
	"Determine which side (class_side or inst_side)
	side := self determineSide: methodName forClass: class.""Find or create method"
	
]

{ #category : 'initialization' }
TypeMeResultsExporter >> processPackage: packageName classes: classesDict [
	"Process a package and its classes"

	| package |
	package := self findOrCreatePackage: packageName.
	classesDict keysAndValuesDo: [ :className :methodsDict |
		self processClass: className inPackage: package methods: methodsDict ]
]

{ #category : 'initialization' }
TypeMeResultsExporter >> processTypeResults: typeResults [
	"Process all type results and update HyDataRepresentation"

	| grouped |
	"Group by package -> class -> method"
	grouped := self groupTypeResults: typeResults.
	grouped keysAndValuesDo: [ :packageName :classesDict |
		self processPackage: packageName classes: classesDict ]
]
