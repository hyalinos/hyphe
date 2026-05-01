Class {
	#name : 'TypeMeConfidentResultsExporter',
	#superclass : 'HyResultsExporter',
	#category : 'Hyphe-Export',
	#package : 'Hyphe',
	#tag : 'Export'
}

{ #category : 'initialization' }
TypeMeConfidentResultsExporter >> initialize [ 

	super initialize.
	defaultSource := #TypeMeConfident
]
