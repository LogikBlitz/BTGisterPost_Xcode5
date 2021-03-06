/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import "NSObject.h"

#import "DVTInvalidation-Protocol.h"
#import "IDEComparisonEditorDataSource-Protocol.h"

@class DVTStackBacktrace, NSMutableDictionary;

@interface IDESnapshotPreviewComparisonEditorDataSource : NSObject <IDEComparisonEditorDataSource, DVTInvalidation>
{
    NSMutableDictionary *_originalFilesToTempDocuments;
    BOOL _isInvalidated;
    DVTStackBacktrace *_invalidationBacktrace;
}

- (void)_cachedDocumentForDocumentLocation:(id)arg1 completionBlock:(id)arg2;
- (id)documentForPrimaryDocumentLocation:(id)arg1 completionBlock:(id)arg2;
- (id)documentForSecondaryDocumentLocation:(id)arg1 completionBlock:(id)arg2;
- (id)init;
- (void)invalidate;
@property(readonly) DVTStackBacktrace *invalidationBacktrace; // @synthesize invalidationBacktrace=_invalidationBacktrace;
@property(readonly, getter=isValid) BOOL valid;

@end

