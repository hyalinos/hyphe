Class {
	#name : 'HyDataDownloader',
	#superclass : 'Object',
	#category : 'Hyphe-Data',
	#package : 'Hyphe',
	#tag : 'Data'
}

{ #category : 'as yet unclassified' }
HyDataDownloader class >> dataFolder [
    | folder |
    folder := FileLocator imageDirectory / 'data'.
    folder asFileReference ensureCreateDirectory .
    ^ folder
]

{ #category : 'as yet unclassified' }
HyDataDownloader class >> downloadFile: url saveWithName: filename [

    | targetFile response|
    targetFile := self dataFolder / filename.
    
    response := ZnClient new
        url: url;
        streaming: true;
        downloadTo: targetFile;
	response.
    
    ^ response isSuccess
]
