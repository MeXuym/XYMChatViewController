//
//  FileUtil.m
//  tianyaClient
//
//  Created by Rocket on 11-8-17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileUtil.h"
#import <CommonCrypto/CommonDigest.h>

@implementation FileUtil

+ (NSString*)documentsPathWithFileName:(NSString*)aFileName
{
    aFileName=aFileName?:@"";
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectory =[paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:aFileName];
}

+ (NSString*)documentsPathWithFileName:(NSString*)aFileName createPathIfNotExists:(BOOL)createPathIfNotExists
{
    aFileName=aFileName?:@"";
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectory =[paths objectAtIndex:0];
    
    //最后一个/之前的是目录
    NSString* dirPath=aFileName;
    NSRange range=[aFileName rangeOfString:@"/" options:NSBackwardsSearch];
    if(range.length>0)
    {
        dirPath=[documentsDirectory stringByAppendingPathComponent:[aFileName substringToIndex:range.location]];
    }
    if (createPathIfNotExists && ![[NSFileManager defaultManager] fileExistsAtPath:dirPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    
    return [documentsDirectory stringByAppendingPathComponent:aFileName];
}

//目录:/var/folders/8p/f38k_sv57sg6yfc7nph27f_m0000gn/T/
+ (NSString*)tempPathWithFileName:(NSString*)filename 
{
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [cacheDir stringByAppendingPathComponent:filename];
} 

//Applications/CD455B1D-8477-4BC3-89CE-882CDF96E15B/Library/Caches
+ (NSString *)cachePathWithFileName:(NSString*)filename
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString* diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
	
    if(filename)
    {
        const char *str = [filename UTF8String];
        unsigned char r[CC_MD5_DIGEST_LENGTH];
        CC_MD5(str, (CC_LONG)strlen(str), r);
        filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                              r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
        
        return [diskCachePath stringByAppendingPathComponent:filename];
    }
    
    return diskCachePath;
}

///Users/black/Library/Application Support/iPhone Simulator/6.0/Applications/BC69A170-FA5F-4737-8E97-05B4BA33A1F2/Library/Caches/DetailCache
+ (NSString *)detailCacheWithFileName:(NSString *)filename
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString* detailCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"DetailCache"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:detailCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:detailCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    
    return [detailCachePath stringByAppendingPathComponent:filename];
}

+(BOOL)fileExists:(NSString*)aFilePath 
{
	return [[NSFileManager defaultManager] fileExistsAtPath:aFilePath]; 
}

+ (BOOL)deleteFileWithPath:(NSString*)aFilePath
{
	BOOL ret=YES;
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:aFilePath])
	{
		ret=[fm removeItemAtPath:aFilePath error:nil]; 
	}
	return ret;
}

+(BOOL)appendData:(NSData*)data path:(NSString*)path
{
	BOOL ret=NO;
	
	NSFileHandle * fh = [NSFileHandle fileHandleForWritingAtPath:path];
	if (!fh)
	{
		ret=[data writeToFile:path atomically:NO];
	}
	else
	{
		[fh truncateFileAtOffset:[fh seekToEndOfFile]];
		[fh writeData:data];
		ret=YES;
	}
	
	return ret;
}

+ (NSDictionary *) getFileAttributes:(NSString*) aFileName {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	//return [fileManager fileAttributesAtPath:aFileName traverseLink:YES];
    return [fileManager attributesOfItemAtPath:aFileName error:nil];
}

+ (NSDate*) getModificationDate:(NSString*) aFileName {
	NSDictionary *fileAttributes = [self getFileAttributes:aFileName];
	NSDate *modificationDate = [NSDate distantPast];
	if(fileAttributes){
		modificationDate = (NSDate*)[fileAttributes objectForKey: NSFileModificationDate];
	}
	return modificationDate;
}

+(long)fileSizeForDir:(NSString*)path
{
    long size=0;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for(int i = 0; i<[array count]; i++)
    {
        NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
        BOOL isDir;
        if ( !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
        {
            NSDictionary *fileAttributeDic=[fileManager attributesOfItemAtPath:fullPath error:nil];
            size += fileAttributeDic.fileSize;
        }
        else
        {
            size += [self fileSizeForDir:fullPath];
        }
    }
    return size;
}

+(void)deleteFileWithDirPath:(NSString*)dirPath matchExtension:(NSString*)extension
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:dirPath error:NULL];  
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) 
    {
        if ([[filename pathExtension] isEqualToString:extension]) 
        {
            [fileManager removeItemAtPath:[dirPath stringByAppendingPathComponent:filename] error:NULL];
        }
    }
}

+(void)deleteHistoryCache
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString* permanentStorePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ASIHTTPRequestCache/PermanentStore"];
    NSString* sessionStorePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ASIHTTPRequestCache/SessionStore"];
    [FileUtil deleteItemsOnlyAtPath:sessionStorePath];
    [FileUtil deleteItemsOnlyAtPath:permanentStorePath];
}

+ (void)deleteItemsOnlyAtPath:(NSString *)path
{
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
	for (int i = 0; i < [dirContents count]; i++)
	{
		NSString *contentsOnly = [NSString stringWithFormat:@"%@/%@", path, [dirContents objectAtIndex:i]];
		[[NSFileManager defaultManager] removeItemAtPath:contentsOnly error:nil];
	}
}

+(void)clearTemporaryDirectory 
{
	NSString *tempPath = NSTemporaryDirectory();
	NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempPath error:nil];
	for (int i = 0; i < [dirContents count]; i++) 
	{
		NSString *contentsOnly = [NSString stringWithFormat:@"%@/%@", tempPath, [dirContents objectAtIndex:i]];
		[[NSFileManager defaultManager] removeItemAtPath:contentsOnly error:nil];
	}
}

@end
