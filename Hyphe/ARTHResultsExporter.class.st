Class {
	#name : 'ARTHResultsExporter',
	#superclass : 'HyResultsExporter',
	#category : 'Hyphe',
	#package : 'Hyphe'
}

{ #category : 'initialization' }
ARTHResultsExporter >> initialize [

	super initialize.
	defaultSource := #ARTHClassifier
]
