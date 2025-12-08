Class {
	#name : 'TypeMeConfidentResultsExporter',
	#superclass : 'TypeMeResultsExporter',
	#category : 'Hyphe-Export',
	#package : 'Hyphe',
	#tag : 'Export'
}

{ #category : 'initialization' }
TypeMeConfidentResultsExporter >> initialize [ 

	super initialize.
	defaultSource := #TypeMeConfident
]
