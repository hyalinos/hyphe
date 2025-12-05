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
    folder := FileLocator imageDirectory / 'Data'.
    folder asFileReference ensureCreateDirectory .
    ^ folder
]

{ #category : 'as yet unclassified' }
HyDataDownloader class >> downloadFile: url saveWithName: filename [
"returns the downloaded file reference"
    | contents |
    
        contents := ZnClient new
            get: url;
            contents.
			
        (self dataFolder / filename) writeStreamDo: [:stream |
            stream nextPutAll: contents ].
^ (self dataFolder / filename) asFileReference 

    
]
