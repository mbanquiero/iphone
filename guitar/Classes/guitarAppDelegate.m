//
//  guitarAppDelegate.m
//  guitar
//
//  Created by user on 15/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "guitarAppDelegate.h"
#import "guitarViewController.h"
#include <AudioUnit/AudioUnit.h>


// samples actual
short int *_pcm = NULL;
int _cant_samples = 0;
float _freq_base = 440;

// sample principal
short int *_pcm1 = NULL;
int _cant_samples1 = 0;
float _freq_base1 = 440;
// sample secundario
short int *_pcm2 = NULL;
int _cant_samples2 = 0;
float _freq_base2 = 440;
// sample auxiliar
short int *_pcm3 = NULL;
int _cant_samples3 = 0;
float _freq_base3 = 440;

int _index;
float _freq[MAX_CANALES];
float _freq_ant[MAX_CANALES];
float _volumen[MAX_CANALES];
int _sample_ndx[MAX_CANALES];

// Sintesis FM
#define DELTA_F			5000		// Desviacion de la frecuencia de la portadora
#define MULT_MOD		2			// Factor de multiplicacion de la onda moduladora

char _tipo_maquina = MAQ_GUITAR;

#define DWORD unsigned int
#define WORD unsigned short



struct RIFF
{
	char ID[4];
	DWORD Size;
	char Format[4];
	
};


//The "WAVE" format consists of two subchunks: "fmt " and "data":
//The "fmt " subchunk describes the sound data's format:

struct FormatChunk
{
	
	char Subchunk1ID[4];	//  Contains the letters "fmt "
	DWORD Subchunk1Size;	//	16 for PCM.  This is the size of the rest of the Subchunk which follows this number.
	WORD AudioFormat;		//  PCM = 1 (i.e. Linear quantization) Values other than 1 indicate some form of compression.
	WORD NumChannels;		//      Mono = 1, Stereo = 2, etc.
	DWORD SampleRate;		//       8000, 44100, etc.
	DWORD ByteRate;			// == SampleRate * NumChannels * BitsPerSample/8
	WORD BlockAlign;		// == NumChannels * BitsPerSample/8 The number of bytes for one sample includingall channels. I wonder what happens when this number isn't an integer?
	WORD BitsPerSample;		//    8 bits = 8, 16 bits = 16, etc.
};


// The "data" subchunk contains the size of the data and the actual sound:

struct DataChunk
{
	char Subchunk2ID[4];	//      Contains the letters "data"
	DWORD Subchunk2Size;	//	NumSamples * NumChannels * BitsPerSample/8 This is the number of bytes in the data.
	// You can also think of this as the size
	// of the read of the subchunk following this  number.
	
};



int generateWav(NSString *fname,short **pcm)
{
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *fileLocation = [bundle pathForResource:fname ofType:@"wav"];
	NSData *file  = [NSData dataWithContentsOfFile:fileLocation];
	const void *bytes = [file bytes];
	
	struct RIFF m_pRiff;
	struct FormatChunk m_pFmt;
	struct DataChunk m_pData;
	int pos = 0;
	memcpy(&m_pRiff,bytes,sizeof(struct RIFF));
	pos+=sizeof(struct RIFF);
	memcpy(&m_pFmt,bytes+pos,sizeof(struct FormatChunk));
	pos+=sizeof(struct FormatChunk);
	
	int extra_bytes = m_pFmt.Subchunk1Size - 16;
	if(extra_bytes)
		pos+=extra_bytes;
	
	memcpy(&m_pData,bytes+pos,sizeof(struct DataChunk));
	pos+=sizeof(struct DataChunk);
	
	// Ahora viene la data pp dicha
	short *data = malloc(m_pData.Subchunk2Size);
	memcpy(data,bytes+pos,m_pData.Subchunk2Size);
	*pcm = data;
	
	// Retorna la cantidad de samples
	return  m_pData.Subchunk2Size/2;
	
}


/*

// Ejemplo que genera un muestreo para un tone de frecuencia fija
// use este ejemplo como base
int *generateTone(int freq, 
				  double lengthMS, 
				  int sampleRate, 
				  double riseTimeMS, 
				  double gain)
{
	int numSamples = ((double) sampleRate) * lengthMS / 1000.;
	int riseTimeSamples = ((double) sampleRate) * riseTimeMS / 1000.;
	
	if(gain > 1.)
		gain = 1.;
	if(gain < 0.)
		gain = 0.;

	if(_pcm)
		free(_pcm);
	_pcm = malloc(numSamples*sizeof(int));
	
	for(int i = 0; i < numSamples; ++i)
	{
		double value = sin(2. * M_PI * freq * i / sampleRate);
		if(i < riseTimeSamples)
			value *= sin(i * M_PI / (2.0 * riseTimeSamples));
		if(i > numSamples - riseTimeSamples - 1)
			value *= sin(2. * M_PI * (i - (numSamples - riseTimeSamples) + riseTimeSamples)/ (4. * riseTimeSamples));
		
		_pcm[i] = (int) (value * 32500.0 * gain);
		_pcm[i] += (_pcm[i]<<16);
	}
	
	_cant_samples = numSamples;
	return _pcm;
	
}
 */

static OSStatus playbackCallback(void *inRefCon, 
								 AudioUnitRenderActionFlags *ioActionFlags, 
								 const AudioTimeStamp *inTimeStamp, 
								 UInt32 inBusNumber, 
								 UInt32 inNumberFrames, 
								 AudioBufferList *ioData) 
{    

	// Cuento la cantidad de canales, para poder sumar las ondas y dividir por el total, y evitar la saturacion
	int cant_canales = 0;
	for(int k=0;k<MAX_CANALES;++k)
		if(_volumen[k])
			cant_canales++;

	// Cuento la cantidad total de samples de todos los buffers
	int totalNumberOfSamples = 0;
	int i;
	int nro_sample = 0;
	for(i = 0; i < ioData->mNumberBuffers; ++i)
		totalNumberOfSamples += ioData->mBuffers[i].mDataByteSize/4;
	
	
	for( i = 0; i < ioData->mNumberBuffers; ++i)
	{
		int cant_samples = ioData->mBuffers[i].mDataByteSize/4;
		for(int j=0;j<cant_samples;++j)
		{
			double total = 0;
			float alfa = (float)nro_sample/(float)totalNumberOfSamples;
			double value;
			double t = (double)_index/(double)SAMPLE_RATE;		// tiempo transcurrido
			int sample = 0;
			for(int k=0;k<MAX_CANALES;++k)
			{
				if(_tipo_maquina==MAQ_GUITAR)
				{
					if(_pcm==NULL)
						value =	sin(2. * M_PI * _freq[k] * t);
						//value =	sin(2. * M_PI * f * t) + sin(4. * M_PI * f * t)*0.73;
					else {
						
					float fndx = _sample_ndx[k]++;
					fndx *= _freq[k]/_freq_base;
					int ndx = fndx;
					if(ndx==0)
						// justo la primer muestra
						value = (float)_pcm[ndx];
					else
					if(ndx<_cant_samples)
					{
						// bilinear sampling
						float fmod = fndx-ndx;
						value = ((float)_pcm[ndx]*fmod) + ((float)_pcm[ndx-1]*(1-fmod));
					}
					else 
						value = 0;
				
					int eco = 10000;
					if(ndx>eco && ndx-eco<_cant_samples)
						value += 0.75*(float)_pcm[ndx-eco];
						
					// normalizo el valor de la muestra (16 bits) a -1,1
					value /= 32500.0;
					}
					
				}
				else
				if(_tipo_maquina==MAQ_PIANO )
				{
					// frecuencia modulada
					// indice de modulacion
					float I = ((float)DELTA_F / (_freq[k]*MULT_MOD));
					float mod = I*cos(2. *M_PI * t * _freq[k] * MULT_MOD);
					value = cos(2. *M_PI * t * _freq[k] + mod);
					if(value>1.0)
						value = 1.0;
					else
						if(value<-1.0)
							value = -1.0;
				}
				else 
				{
				   
					// interpolo la frecuencia anterior y la actual, de acuerdo al numero de muestra
					// para intentar evitar el "tac" al variar la frecuencia
					float f;
					if(_tipo_maquina==MAQ_RUIDO)
						f = _freq[k]*alfa + _freq_ant[k]*(1-alfa);
					else 
						f = _freq[k];
					
					if(_tipo_maquina==MAQ_RUIDO_3)
						value =	sin(2. * M_PI * f * t) + sin(4. * M_PI * f * t)*0.3 + sin(16.*M_PI*f*t)*0.2;
					else
						value =	sin(2. * M_PI * f * t);

				}

				// Calculo el valor de la muestra y mezlco (sumo) las señales
				//sample += (int) (value * 32500.0 * _volumen[k]);				
				total += value*_volumen[k];
			}	
			
			// evito que se sature, divido por la cantidad de canales con señal 
			if(cant_canales>1)
			{
				if(_pcm!=NULL)
					total/=sqrt(2*cant_canales);
				else
					total*=(float)cant_canales/(float)(cant_canales+1);
			}
			// de todas formas hago un clamp entre -1 y 1
			if(total>1.0)
				total = 1.0;
			else
			if(total<-1.0)
				total = -1.0;
			sample = (int) (total * 32500.0);	
						
			// estereo: el left y el rigth el mismo valor :
			sample += (sample<<16);

			// copio la memoria. cada muetra tiene 4 bytes, porque son 16bits x 2 porque es estereo,
			// (Si fuese mono, tendria solo 2 bytes, pero de momento uso todo estereo)
			memcpy((char *)ioData->mBuffers[i].mData+j*4, &sample, 4);
			++_index;
			++nro_sample;
		}
		
	}
	
	for(int k=0;k<MAX_CANALES;++k)
		_freq_ant[k] = _freq[k];

    return noErr;
}




@implementation guitarAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	_index = 0;
	for(int k=0;k<MAX_CANALES;++k)
	{
		_freq_ant[k] = _freq[k] = 0;
		_sample_ndx[k] = 0;
	}	
	
	// Genero los samples principales  secundarios desde los archivos .WAV
	_cant_samples1 = generateWav(@"C4",&_pcm1);
	_freq_base1 = 261.6;		// C4 
	// estos son todos LA 220, asi que los dejo como estan
	_cant_samples2 = generateWav(@"TEST",&_pcm2); 
	_freq_base2 = 440;	 
	_cant_samples3 = generateWav(@"ks-B3",&_pcm3); 
	_freq_base3 = 220;	 
	
	
	// Esto lo curre de la doc. de apple y de un blog que explica como acceder a un AudioUnit:
	OSStatus status;
	AudioComponentInstance audioUnit;
	
	// Describe audio component
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output;
	desc.componentSubType = kAudioUnitSubType_RemoteIO;
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	// Get component
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
	
	// Get audio units
	status = AudioComponentInstanceNew(inputComponent, &audioUnit);
	//checkStatus(status);
	
	UInt32 flag = 1;
	// Enable IO for playback
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioOutputUnitProperty_EnableIO, 
								  kAudioUnitScope_Output, 
								  kOutputBus,
								  &flag, 
								  sizeof(flag));
	//checkStatus(status);
	
	// Describe format
	AudioStreamBasicDescription audioFormat;
	audioFormat.mSampleRate = SAMPLE_RATE;
	audioFormat.mFormatID	= kAudioFormatLinearPCM;
	audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	audioFormat.mFramesPerPacket = 1;
	audioFormat.mChannelsPerFrame = 2;
	audioFormat.mBitsPerChannel = 16;
	audioFormat.mBytesPerPacket = 4;
	audioFormat.mBytesPerFrame = 4;
	
	// Apply format
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Input, 
								  kOutputBus, 
								  &audioFormat, 
								  sizeof(audioFormat));
	//  checkStatus(status);
	
	// Aca esta la papa: esta funcion es la que se va a llamar continuamente cada vez que necesite datos el audiounit
	// Set output callback
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = playbackCallback;
	callbackStruct.inputProcRefCon = self;
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_SetRenderCallback, 
								  kAudioUnitScope_Global, 
								  kOutputBus,
								  &callbackStruct, 
								  sizeof(callbackStruct));
	
	// Initialize
	status = AudioUnitInitialize(audioUnit);
	
	// Start playing
	status = AudioOutputUnitStart(audioUnit);
	
	// habilito el multitouch en el view, OJO x defecto no esta habilitado, y sin esta instruccion no genera 
	// eventos para mas de un dedo al mismo tiempo.
	// En mi ipod por lo visto solo toma los primeros 4 dedos al mismo tiempo. 
	viewController.view.multipleTouchEnabled = YES;

    // Add the view controller's view to the window and display.
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
