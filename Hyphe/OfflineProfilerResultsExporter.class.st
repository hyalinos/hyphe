Class {
	#name : 'OfflineProfilerResultsExporter',
	#superclass : 'TypeMeResultsExporter',
	#category : 'Hyphe-Export',
	#package : 'Hyphe',
	#tag : 'Export'
}

{ #category : 'initialization' }
OfflineProfilerResultsExporter >> initialize [     
	 super initialize.
    defaultSource := 'Offline Test Profiling'.
]
