Class {
	#name : 'ARTIResultsExporter',
	#superclass : 'HyResultsExporter',
	#category : 'Hyphe',
	#package : 'Hyphe'
}

{ #category : 'initialization' }
ARTIResultsExporter >> initialize [

	super initialize.
	defaultSource := #ARTIReturnTypeInferrer
]
