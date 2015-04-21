/*
 * C1Pro.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class C1ProApplication, C1ProWindow, C1ProApplication, C1ProDocument, C1ProCamera, C1ProCollection, C1ProRecipe, C1ProWatermark, C1ProJob, C1ProVariant, C1ProImage;

enum C1ProNextcaptureadjustments {
	C1ProNextcaptureadjustmentsDefault = 'NCda',
	C1ProNextcaptureadjustmentsLast = 'NCla',
	C1ProNextcaptureadjustmentsPrimary = 'NCpa',
	C1ProNextcaptureadjustmentsCustom = 'NCca',
	C1ProNextcaptureadjustmentsDefaultWithStyle = 'Ndsa',
	C1ProNextcaptureadjustmentsLastUsingClipboard = 'Nluc',
	C1ProNextcaptureadjustmentsPrimaryUsingClipboard = 'Npuc',
	C1ProNextcaptureadjustmentsUsingClipboard = 'NCuc',
	C1ProNextcaptureadjustmentsLastWithVariants = 'Nlwv',
	C1ProNextcaptureadjustmentsPrimaryWithVariants = 'Npwv'
};
typedef enum C1ProNextcaptureadjustments C1ProNextcaptureadjustments;

enum C1ProShutterlatency {
	C1ProShutterlatencyNormalLatency = 'SLNo' /* Normal(Long) Shutter Latency */,
	C1ProShutterlatencyZeroLatency = 'SLZe' /* Zero(Short) Shutter Latency */,
	C1ProShutterlatencyUnknownLatency = 'SLUn' /* Unknown Shutter Latency - may not be supported */
};
typedef enum C1ProShutterlatency C1ProShutterlatency;

enum C1ProDocumentType {
	C1ProDocumentTypeSession = 'COsd' /* Session document. */,
	C1ProDocumentTypeCatalog = 'COct' /* Catalog document. */
};
typedef enum C1ProDocumentType C1ProDocumentType;

enum C1ProCollectionType {
	C1ProCollectionTypeFavorite = 'CCfv',
	C1ProCollectionTypeAlbum = 'CCal',
	C1ProCollectionTypeGroup = 'CCgp',
	C1ProCollectionTypeProject = 'CCpj',
	C1ProCollectionTypeSmartAlbum = 'CCsm'
};
typedef enum C1ProCollectionType C1ProCollectionType;

enum C1ProRecipeFileFormat {
	C1ProRecipeFileFormatJPEG = 'Rjpg',
	C1ProRecipeFileFormatJPEG_QuickProof = 'Rjqp',
	C1ProRecipeFileFormatJPEG_XR = 'Rjxr',
	C1ProRecipeFileFormatJPEG_2000 = 'Rj2K',
	C1ProRecipeFileFormatTIFF = 'Rtif',
	C1ProRecipeFileFormatDNG = 'Rdng',
	C1ProRecipeFileFormatPNG = 'Rpng',
	C1ProRecipeFileFormatPSD = 'Rpsd'
};
typedef enum C1ProRecipeFileFormat C1ProRecipeFileFormat;

enum C1ProTiffCompress {
	C1ProTiffCompressNone = 'Rtno',
	C1ProTiffCompressLZW = 'Rtlz',
	C1ProTiffCompressZIP = 'Rtzp'
};
typedef enum C1ProTiffCompress C1ProTiffCompress;

enum C1ProScalingType {
	C1ProScalingTypeFixed = 'Rsfx',
	C1ProScalingTypeWidth = 'Rswd',
	C1ProScalingTypeHeight = 'Rsht',
	C1ProScalingTypeBoundingDimensions = 'Rsdm',
	C1ProScalingTypeWidth_by_Height = 'Rswh',
	C1ProScalingTypeLong_Edge = 'Rsle',
	C1ProScalingTypeShort_Edge = 'Rsse'
};
typedef enum C1ProScalingType C1ProScalingType;

enum C1ProMeasurementUnit {
	C1ProMeasurementUnitPixels = 'MUpx',
	C1ProMeasurementUnitInches = 'MUin',
	C1ProMeasurementUnitMillimeters = 'MUmm',
	C1ProMeasurementUnitCentimeters = 'MUcm',
	C1ProMeasurementUnitPercent = 'MUpr'
};
typedef enum C1ProMeasurementUnit C1ProMeasurementUnit;

enum C1ProRecipeRootType {
	C1ProRecipeRootTypeOutput = 'Rrof',
	C1ProRecipeRootTypeImage = 'Rrif',
	C1ProRecipeRootTypeCustom = 'Rrcu'
};
typedef enum C1ProRecipeRootType C1ProRecipeRootType;

enum C1ProWatermarkKind {
	C1ProWatermarkKindTextual = 'CRWt',
	C1ProWatermarkKindImagery = 'CRWi',
	C1ProWatermarkKindNone = 'CRWn'
};
typedef enum C1ProWatermarkKind C1ProWatermarkKind;



/*
 * Standard Suite
 */

// The application's top-level scripting object.
@interface C1ProApplication : SBApplication

- (SBElementArray *) documents;
- (SBElementArray *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the active application?
@property (copy, readonly) NSString *version;  // The version number of the application.

- (void) open:(NSArray *)x;  // Open a document.
- (void) quit;  // Quit the application.
- (void) beginLiveView;  // Open Live View for the currently selected camera.
- (NSString *) process:(id)x recipe:(NSString *)recipe;  // (PRO Only) Process a variant, or the variants of a RAW file
- (void) capture;  // (PRO Only) Try to start capturing with the currently selected camera into the foreground document.  Follow with a delay command in order to allow the image to be fully captured before continuing in the same script.

@end

// A window.
@interface C1ProWindow : SBObject

@property (copy, readonly) NSString *name;  // The title of the window.
- (NSInteger) id;  // The unique identifier of the window.
@property NSInteger index;  // The index of the window, ordered front to back.
@property NSRect bounds;  // The bounding rectangle of the window.
@property (readonly) BOOL closeable;  // Does the window have a close button?
@property (readonly) BOOL miniaturizable;  // Does the window have a minimize button?
@property BOOL miniaturized;  // Is the window minimized right now?
@property (readonly) BOOL resizable;  // Can the window be resized?
@property BOOL visible;  // Is the window visible right now?
@property (readonly) BOOL zoomable;  // Does the window have a zoom button?
@property BOOL zoomed;  // Is the window zoomed right now?
@property (copy, readonly) C1ProDocument *document;  // The document whose contents are displayed in the window.

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end



/*
 * Capture One Suite
 */

// Capture One application class.
@interface C1ProApplication (CaptureOneSuite)

- (SBElementArray *) documents;
- (SBElementArray *) images;

@property (copy) id captureDoneScript;  // (PRO Only) The AppleScript that gets called when an image has completed being captured.
@property (copy) id processingDoneScript;  // (PRO Only) The AppleScript that gets called when a file is finished processing. The script is passed the identifier string of the finished batch job in argv 1, the original RAW file path in argv 2, and a list of the output file paths in argv 3.
@property (copy) id batchDoneScript;  // (PRO Only) The AppleScript that gets called when the batch process queue completes.
@property (copy) id liveViewBecameReadyScript;  // (PRO Only) The AppleScript that gets called when Live View has become ready.
@property (copy) id liveViewWillCloseScript;  // (PRO Only) The AppleScript that gets called when Live View is about to close.
@property (copy) id liveViewDoneScript;  // (PRO Only) The AppleScript that gets called when Live View is closed.
@property (copy, readonly) NSArray *selectedVariants;  // List of selected variants
@property (copy, readonly) NSString *appVersion;  // The version of Capture One
@property (copy, readonly) C1ProVariant *primaryVariant;  // The primary selected variant
@property C1ProNextcaptureadjustments nextCaptureAdjustments;  // (PRO Only) When an image is captured, what adjustments should be applied?
@property C1ProShutterlatency shutterLatency;  // (PRO Only) Choose the Shutter Latency Mode used when capturing. Only has an effect when a camera is connected.

@end

// A Capture One document.  Contained variant elements are the selected variants only.
@interface C1ProDocument : SBObject

- (SBElementArray *) images;
- (SBElementArray *) recipes;
- (SBElementArray *) jobs;
- (SBElementArray *) collections;
- (SBElementArray *) variants;

@property (copy, readonly) NSString *name;  // The name of the document.
@property (copy, readonly) id path;  // The folder item containing the document.
@property (readonly) C1ProDocumentType kind;  // The kind of document.
@property (copy) id output;  // The Output folder item.
@property (copy) id captures;  // The Capture folder item.
@property (copy) id selects;  // The Selects folder item (Session only).
@property (copy) id trash;  // The Trash folder item (Session only).
@property BOOL processingQueueEnabled;  // Whether or not the output processing batch job queue is running.  Can be changed.
@property (copy) NSString *outputNameFormat;  // The current process output naming format.
@property (copy) NSString *outputName;  // The current process output job name.
@property NSInteger captureCounter;
@property NSInteger captureCounterIncrement;
@property (copy) NSString *captureNameFormat;  // The current next capture naming format.
@property (copy) NSString *captureName;  // The current next capture name.
@property (copy, readonly) NSURL *lastCapturedFile;  // The last captured image file.
@property (copy, readonly) C1ProCamera *camera;  // The selected camera.

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) activate;  // Become the foreground, active document.
- (void) selectCameraName:(NSString *)name;  // Select a tethered camera to use by name.  Follow with a delay command in order to use the chosen camera immediately afterward in the same script.
- (void) browseToPath:(NSString *)toPath;  // Change the folder being browsed.

@end

// A camera. Not all properties are supported by all cameras.
@interface C1ProCamera : SBObject

@property (copy, readonly) NSString *name;  // The name of the camera.
@property (copy) NSString *format;  // Current image format.
@property (copy) NSString *sensorPlus;  // Current Sensor+ setting.
@property (copy) NSString *imageArea;  // Current image area format.
@property (copy) NSString *ISO;  // Current ISO setting.
@property (copy) NSString *whiteBalance;  // Current white balance setting.
@property (copy) NSString *program;  // Current exposure program mode.
@property (copy) NSString *exposureStep;  // Current exposure step.
@property (copy) NSString *shutterSpeed;  // Current shutter speed.
@property (copy) NSString *aperture;  // Current aperture setting.
@property (copy) NSString *EVAdjustment;  // Current exposure value adjustment.
@property (copy) NSString *flashMode;  // Current flash mode.
@property (copy) NSString *meteringMode;  // Current metering mode.
@property (copy, readonly) NSString *meterValue;  // Current meter value.
@property (copy, readonly) NSString *availableFormats;  // The camera's possible image formats (delimited by |'s).
@property (copy, readonly) NSString *availableSensorPlusSettings;  // The camera's possible Sensor+ settings (delimited by |'s).
@property (copy, readonly) NSString *availableImageAreaSettings;  // The camera's possible image area settings (delimited by |'s).
@property (copy, readonly) NSString *availableISOSettings;  // The camera's possible ISO settings (delimited by |'s).
@property (copy, readonly) NSString *availableWhiteBalanceSettings;  // The camera's possible white balance settings (delimited by |'s).
@property (copy, readonly) NSString *availablePrograms;  // The camera's possible programs (delimited by |'s).
@property (copy, readonly) NSString *availableExposureSteps;  // The camera's possible exposure steps (delimited by |'s).
@property (copy, readonly) NSString *availableShutterSpeeds;  // The camera's possible shutter speeds (delimited by |'s).
@property (copy, readonly) NSString *availableApertureSettings;  // The camera's possible aperture settings (delimited by |'s).
@property (copy, readonly) NSString *availableEVAdjustments;  // The camera's possible exposure value adjustments (delimited by |'s).
@property (copy, readonly) NSString *availableFlashModes;  // The camera's possible flash modes (delimited by |'s).
@property (copy, readonly) NSString *availableMeteringModes;  // The camera's possible metering modes (delimited by |'s).

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end

// An organizational collection.
@interface C1ProCollection : SBObject

- (SBElementArray *) collections;

@property (copy, readonly) NSString *name;
@property (readonly) C1ProCollectionType kind;
@property (copy, readonly) NSURL *file;  // The folder location referred to by the collection, if appropriate.

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end

// A Capture One process recipe.
@interface C1ProRecipe : SBObject

@property (copy) NSString *name;  // The name of the recipe.
@property BOOL enabled;  // Whether or not the recipe is enabled.
@property C1ProRecipeFileFormat outputFormat;  // The output file format of the recipe.
@property NSInteger bits;  // The bit depth of the output file.
@property NSInteger JPEGQuality;  // The JPEG quality of the output file.
@property C1ProTiffCompress TIFFCompression;  // The TIFF compression type of the output file.
@property (copy) NSString *colorProfile;  // The name of the ICC color profile to be applied.
@property (copy) NSNumber *pixelsPerInch;  // The resolution of the output file.
@property C1ProScalingType scalingMethod;  // The scaling method for the output file.
@property C1ProMeasurementUnit scalingUnit;  // The scaling units used by current scaling method.
@property (copy) NSNumber *primaryScalingValue;  // Primary value used by current scaling method.
@property (copy) NSNumber *secondaryScalingValue;  // Secondary value used by current scaling method (BoundingDimensions and Width_by_Height methods only).
@property BOOL upscale;  // Whether or not output can be upscaled beyond the original size.
@property (copy) NSURL *application;  // Output file's 'Open With' application.
@property C1ProRecipeRootType rootFolderType;  // The recipe's type of root folder.
@property (copy) NSURL *rootFolderLocation;  // The output root folder location.
@property (copy) NSString *outputSubName;  // The output sub name.
@property (copy) NSString *outputSubFolder;  // The output sub folder.
@property BOOL thumbnails;  // Whether or not thumbnails should be created.
@property BOOL sharpened;  // Whether or not output image should be sharpened.
@property BOOL ignoreCrop;  // Whether or not the default crop should be used in place of the current crop.
@property BOOL includeRatings;  // Whether or not rating and color tags should be included.
@property BOOL includeCopyright;  // Whether or not copyright metadata should be included.
@property BOOL includeGPS;  // Whether or not GPS metadata should be included.
@property BOOL includeCameraMetadata;  // Whether or not camera metadata should be included.
@property BOOL includeOtherMetadata;  // Whether or not other metadata should be included.
@property (copy) C1ProWatermark *watermark;  // The watermark of the recipe.

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end

// A recipe watermark.  Properties are specific to the kind of watermark, so ensure that the kind is what you want before accessing a watermark's properties.
@interface C1ProWatermark : SBObject

@property C1ProWatermarkKind kind;  // The kind of watermark.
@property (copy) NSString *image;  // The image path.
@property (copy) NSString *label;  // The text.
@property (copy) NSColor *color;  // The text color.
@property NSInteger size;  // The text size in points.
@property (copy) NSString *font;  // The text font name.
@property NSInteger opacity;  // The opacity (1 to 100).
@property NSInteger scale;  // The scale (25 to 400).
@property (copy) NSNumber *x;  // The horizontal position (-55 to 55).
@property (copy) NSNumber *y;  // The vertical position (-55 to 55).

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end

// A pending job from a Capture One document's batch processing queue.
@interface C1ProJob : SBObject

- (SBElementArray *) recipes;

@property (copy, readonly) NSString *imageName;  // The filename of the original image to be processed.
@property (copy, readonly) NSString *imagePath;  // The full path to the original image to be processed.

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end

// An Image Variant
@interface C1ProVariant : SBObject

@property (copy, readonly) C1ProImage *parentImage;  // The parent image of the variant
@property NSRect crop;  // The variant's crop rectangle {centerX, centerY, width, height}
@property NSPoint cropSize;  // The size of the crop in pixels {width, height}
@property NSInteger cropWidth;  // The width (in pixels) of the variant's crop
@property NSInteger cropHeight;  // The height (in pixels) of the variant's crop
@property NSPoint cropCenter;  // The center of the crop in pixels {x, y} Bottom Left is the origin
@property NSInteger cropCenterX;  // The horizontal center (in pixels) of the variant's crop (relative to Left edge)
@property NSInteger cropCenterY;  // The vertical center (in pixels) of the variant's crop (relative to bottom edge)

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (NSString *) processRecipe:(NSString *)recipe;  // (PRO Only) Process a variant, or the variants of a RAW file
- (void) autocrop;  // Auto crop a variant

@end

// An Image, pointing to a RAW file
@interface C1ProImage : SBObject

- (SBElementArray *) variants;

@property (copy, readonly) NSString *path;  // The full path to the original RAW file
@property (copy, readonly) NSString *name;  // The name of the image file
- (NSString *) id;  // The ID of the image
@property (readonly) NSPoint dimensions;  // The dimensions of the image in pixels {width, height}

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (BOOL) addVariantAdditiveSelect:(BOOL)additiveSelect;  // Add a new Variant eg. "tell myImage to add variant"

@end

