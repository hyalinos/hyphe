Class {
	#name : 'CTIResultsExporter',
	#superclass : 'HyResultsExporter',
	#category : 'Hyphe',
	#package : 'Hyphe'
}

{ #category : 'initialization' }
CTIResultsExporter >> initialize [

	super initialize.
	defaultSource := #CTIInferer
]
