{ *******************************************************************************

  The contents of this file are subject to the Mozilla Public License
  Version 1.1 (the "License"); you may not use this file except in
  compliance with the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL/

  Software distributed under the License is distributed on an "AS IS"
  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
  License for the specific language governing rights and limitations
  under the License.

  ******************************************************************************* }

unit wbBSArchive;

interface

uses
  SysUtils,
  Classes,
  Windows,
  Threading,
  wbStreams,
  tfTypes,
  tfMD5;

type
  TMagic4 = array [0 .. 3] of AnsiChar;
  PMagic4 = ^TMagic4;

  TDXGI = (DXGI_FORMAT_UNKNOWN, DXGI_FORMAT_R32G32B32A32_TYPELESS,
    DXGI_FORMAT_R32G32B32A32_FLOAT, DXGI_FORMAT_R32G32B32A32_UINT,
    DXGI_FORMAT_R32G32B32A32_SINT, DXGI_FORMAT_R32G32B32_TYPELESS,
    DXGI_FORMAT_R32G32B32_FLOAT, DXGI_FORMAT_R32G32B32_UINT,
    DXGI_FORMAT_R32G32B32_SINT, DXGI_FORMAT_R16G16B16A16_TYPELESS,
    DXGI_FORMAT_R16G16B16A16_FLOAT, DXGI_FORMAT_R16G16B16A16_UNORM,
    DXGI_FORMAT_R16G16B16A16_UINT, DXGI_FORMAT_R16G16B16A16_SNORM,
    DXGI_FORMAT_R16G16B16A16_SINT, DXGI_FORMAT_R32G32_TYPELESS,
    DXGI_FORMAT_R32G32_FLOAT, DXGI_FORMAT_R32G32_UINT, DXGI_FORMAT_R32G32_SINT,
    DXGI_FORMAT_R32G8X24_TYPELESS, DXGI_FORMAT_D32_FLOAT_S8X24_UINT,
    DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS, DXGI_FORMAT_X32_TYPELESS_G8X24_UINT,
    DXGI_FORMAT_R10G10B10A2_TYPELESS, DXGI_FORMAT_R10G10B10A2_UNORM,
    DXGI_FORMAT_R10G10B10A2_UINT, DXGI_FORMAT_R11G11B10_FLOAT,
    DXGI_FORMAT_R8G8B8A8_TYPELESS, DXGI_FORMAT_R8G8B8A8_UNORM,
    DXGI_FORMAT_R8G8B8A8_UNORM_SRGB, DXGI_FORMAT_R8G8B8A8_UINT,
    DXGI_FORMAT_R8G8B8A8_SNORM, DXGI_FORMAT_R8G8B8A8_SINT,
    DXGI_FORMAT_R16G16_TYPELESS, DXGI_FORMAT_R16G16_FLOAT,
    DXGI_FORMAT_R16G16_UNORM, DXGI_FORMAT_R16G16_UINT, DXGI_FORMAT_R16G16_SNORM,
    DXGI_FORMAT_R16G16_SINT, DXGI_FORMAT_R32_TYPELESS, DXGI_FORMAT_D32_FLOAT,
    DXGI_FORMAT_R32_FLOAT, DXGI_FORMAT_R32_UINT, DXGI_FORMAT_R32_SINT,
    DXGI_FORMAT_R24G8_TYPELESS, DXGI_FORMAT_D24_UNORM_S8_UINT,
    DXGI_FORMAT_R24_UNORM_X8_TYPELESS, DXGI_FORMAT_X24_TYPELESS_G8_UINT,
    DXGI_FORMAT_R8G8_TYPELESS, DXGI_FORMAT_R8G8_UNORM, DXGI_FORMAT_R8G8_UINT,
    DXGI_FORMAT_R8G8_SNORM, DXGI_FORMAT_R8G8_SINT, DXGI_FORMAT_R16_TYPELESS,
    DXGI_FORMAT_R16_FLOAT, DXGI_FORMAT_D16_UNORM, DXGI_FORMAT_R16_UNORM,
    DXGI_FORMAT_R16_UINT, DXGI_FORMAT_R16_SNORM, DXGI_FORMAT_R16_SINT,
    DXGI_FORMAT_R8_TYPELESS, DXGI_FORMAT_R8_UNORM, DXGI_FORMAT_R8_UINT,
    DXGI_FORMAT_R8_SNORM, DXGI_FORMAT_R8_SINT, DXGI_FORMAT_A8_UNORM,
    DXGI_FORMAT_R1_UNORM, DXGI_FORMAT_R9G9B9E5_SHAREDEXP,
    DXGI_FORMAT_R8G8_B8G8_UNORM, DXGI_FORMAT_G8R8_G8B8_UNORM,
    DXGI_FORMAT_BC1_TYPELESS, DXGI_FORMAT_BC1_UNORM, DXGI_FORMAT_BC1_UNORM_SRGB,
    DXGI_FORMAT_BC2_TYPELESS, DXGI_FORMAT_BC2_UNORM, DXGI_FORMAT_BC2_UNORM_SRGB,
    DXGI_FORMAT_BC3_TYPELESS, DXGI_FORMAT_BC3_UNORM, DXGI_FORMAT_BC3_UNORM_SRGB,
    DXGI_FORMAT_BC4_TYPELESS, DXGI_FORMAT_BC4_UNORM, DXGI_FORMAT_BC4_SNORM,
    DXGI_FORMAT_BC5_TYPELESS, DXGI_FORMAT_BC5_UNORM, DXGI_FORMAT_BC5_SNORM,
    DXGI_FORMAT_B5G6R5_UNORM, DXGI_FORMAT_B5G5R5A1_UNORM,
    DXGI_FORMAT_B8G8R8A8_UNORM, DXGI_FORMAT_B8G8R8X8_UNORM,
    DXGI_FORMAT_R10G10B10_XR_BIAS_A2_UNORM, DXGI_FORMAT_B8G8R8A8_TYPELESS,
    DXGI_FORMAT_B8G8R8A8_UNORM_SRGB, DXGI_FORMAT_B8G8R8X8_TYPELESS,
    DXGI_FORMAT_B8G8R8X8_UNORM_SRGB, DXGI_FORMAT_BC6H_TYPELESS,
    DXGI_FORMAT_BC6H_UF16, DXGI_FORMAT_BC6H_SF16, DXGI_FORMAT_BC7_TYPELESS,
    DXGI_FORMAT_BC7_UNORM, DXGI_FORMAT_BC7_UNORM_SRGB, DXGI_FORMAT_AYUV,
    DXGI_FORMAT_Y410, DXGI_FORMAT_Y416, DXGI_FORMAT_NV12, DXGI_FORMAT_P010,
    DXGI_FORMAT_P016, DXGI_FORMAT_420_OPAQUE, DXGI_FORMAT_YUY2,
    DXGI_FORMAT_Y210, DXGI_FORMAT_Y216, DXGI_FORMAT_NV11, DXGI_FORMAT_AI44,
    DXGI_FORMAT_IA44, DXGI_FORMAT_P8, DXGI_FORMAT_A8P8,
    DXGI_FORMAT_B4G4R4A4_UNORM, DXGI_FORMAT_P208, DXGI_FORMAT_V208,
    DXGI_FORMAT_V408);

  TDDSHeader = packed record
    Magic: TMagic4;
    dwSize: Cardinal;
    dwFlags: Cardinal;
    dwHeight: Cardinal;
    dwWidth: Cardinal;
    dwPitchOrLinearSize: Cardinal;
    dwDepth: Cardinal;
    dwMipMapCount: Cardinal;
    dwReserved1: array [0 .. 10] of Cardinal;

    ddspf: packed record
      dwSize: Cardinal;
      dwFlags: Cardinal;
      dwFourCC: TMagic4;
      dwRGBBitCount: Cardinal;
      dwRBitMask: Cardinal;
      dwGBitMask: Cardinal;
      dwBBitMask: Cardinal;
      dwABitMask: Cardinal;
    end;

    dwCaps: Cardinal;
    dwCaps2: Cardinal;
    dwCaps3: Cardinal;
    dwCaps4: Cardinal;
    dwReserved2: Cardinal;
  end;

  PDDSHeader = ^TDDSHeader;

  TDDSHeaderDX10 = packed record
    dxgiFormat: Integer;
    resourceDimension: Cardinal;
    miscFlags: Cardinal;
    arraySize: Cardinal;
    miscFlags2: Cardinal;
  end;

  PDDSHeaderDX10 = ^TDDSHeaderDX10;

  TwbBSArchive = class;

  TBSArchiveType = (baNone, baTES3, baTES4, baFO3, baSSE, baFO4, baFO4dds);
  TBSArchiveState = (stReading, stWriting);
  TBSArchiveStates = set of TBSArchiveState;
  TBSFileIterationProcCompat = function(aArchive: Pointer;
    const aFilePath: PChar; aFileRecord: Pointer; aFolderRecord: Pointer;
    aContext: Pointer): Boolean; stdcall;

  TDDSInfo = record
    Width, Height, MipMaps: Integer;
  end;

  TBSFileDDSInfoProcCompat = procedure(aArchive: Pointer;
    const aFilePath: PChar; var aInfo: TDDSInfo; aContext: Pointer); stdcall;

  TwbBSHeaderTES3 = packed record
    HashOffset: Cardinal;
    FileCount: Cardinal;
  end;

  TwbBSFileTES3 = record
    Hash: UInt64;
    Size: Cardinal;
    Offset: Cardinal;
    Name: string;
  end;

  PwbBSFileTES3 = ^TwbBSFileTES3;

  TwbBSHeaderTES4 = packed record
    FoldersOffset: Cardinal;
    Flags: Cardinal;
    FolderCount: Cardinal;
    FileCount: Cardinal;
    FolderNamesLength: Cardinal;
    FileNamesLength: Cardinal;
    FileFlags: Cardinal;
  end;

  TwbBSFileTES4 = record
    Hash: UInt64;
    Size: Cardinal;
    Offset: Int64;
    Name: string;
    function Compressed(bsa: TwbBSArchive): Boolean;
    function RawSize: Cardinal;
  end;

  PwbBSFileTES4 = ^TwbBSFileTES4;

  TwbBSFolderTES4 = record
    Hash: UInt64;
    FileCount: Cardinal;
    Unk32: Cardinal;
    Offset: Int64;
    Name: string;
    Files: array of TwbBSFileTES4;
  end;

  PwbBSFolderTES4 = ^TwbBSFolderTES4;

  TwbBSHeaderFO4 = packed record
    Magic: TMagic4;
    FileCount: Cardinal;
    FileTableOffset: Int64;
  end;

  TwbBSTexChunkRec = record
    Size: Cardinal;
    PackedSize: Cardinal;
    Offset: Int64;
    StartMip: Word;
    EndMip: Word;
  end;

  PwbBSTexChunkRec = ^TwbBSTexChunkRec;

  TwbBSFileFO4 = record
    NameHash: Cardinal;
    Ext: TMagic4;
    DirHash: Cardinal;
    // GNRL archive format
    Unknown: Cardinal;
    Offset: Int64;
    PackedSize: Cardinal;
    Size: Cardinal;
    //
    // DX10 archive format
    UnknownTex: Byte;
    // ChunkHeaderSize: Word;
    Height: Word;
    Width: Word;
    NumMips: Byte;
    dxgiFormat: Byte;
    CubeMaps: Word;
    TexChunks: array of TwbBSTexChunkRec;
    //
    Name: string;
    function DXGIFormatName: string;
  end;

  PwbBSFileFO4 = ^TwbBSFileFO4;

  TPackedDataHash = TMD5Digest;

  TPackedDataInfo = record
    Size: Cardinal;
    Hash: TPackedDataHash;
    FileRecord: Pointer;
  end;

  PPackedDataInfo = ^TPackedDataInfo;

  TwbBSResultBuffer = packed record
    Size: Cardinal;
    data: PByte;
  end;

  TwbBSEntryList = class(TStringList);

  TwbBSArchive = class
  private
    fStream: TwbBaseCachedFileStream;
    fStates: TBSArchiveStates;
    fType: TBSArchiveType;
    fFileName: string;
    fMagic: TMagic4;
    fVersion: Cardinal;
    fCompress: Boolean;
    fShareData: Boolean;

    fDDSInfoProc: TBSFileDDSInfoProcCompat;
    fDDSInfoProcContext: Pointer;

    fHeaderTES3: TwbBSHeaderTES3;
    fFilesTES3: array of TwbBSFileTES3;

    fHeaderTES4: TwbBSHeaderTES4;
    fFoldersTES4: array of TwbBSFolderTES4;

    fHeaderFO4: TwbBSHeaderFO4;
    fFilesFO4: array of TwbBSFileFO4;
    fMaxChunkCount: Integer;
    fSingleMipChunkX: Integer;
    fSingleMipChunkY: Integer;

    fDataOffset: Int64;

    fPackedData: array of TPackedDataInfo;
    fPackedDataCount: Integer;

    function GetArchiveFormatName: string;
    function GetFileCount: Cardinal;
    procedure SetArchiveFlags(aFlags: Cardinal);
    function FindFileRecordTES3(const aFilePath: string;
      var aFileIdx: Integer): Boolean;
    function FindFileRecordTES4(const aFilePath: string;
      var aFolderIdx, aFileIdx: Integer): Boolean;
    function FindFileRecordFO4(const aFilePath: string;
      var aFileIdx: Integer): Boolean;
    function GetDDSMipChunkNum(var aDDSInfo: TDDSInfo): Integer;
    function CalcDataHash(aData: Pointer; aLen: Cardinal): TPackedDataHash;
    function FindPackedData(aSize: Cardinal; aHash: TPackedDataHash;
      aFileRecord: Pointer): Boolean;
    procedure AddPackedData(aSize: Cardinal; aHash: TPackedDataHash;
      aFileRecord: Pointer);

  public
    Sync: IReadWriteSync;
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const aFilePath: string);
    procedure CreateArchiveCompat(const aFilePath: string;
      aType: TBSArchiveType; aFilesList: TwbBSEntryList = nil);
    procedure Save;

    procedure AddFileDisk(const aFilePath, aSourcePath: string);
    procedure AddFileDiskRoot(const aRootDir, aSourcePath: string);
    procedure AddFileDataCompat(const aFilePath: string; const aSize: Cardinal;
      const aData: PByte);
    function FindFileRecord(const aFilePath: string): Pointer;
    function ExtractFileDataCompat(aFileRecord: Pointer)
      : TwbBSResultBuffer; overload;
    function ExtractFileDataCompat(const aFilePath: string)
      : TwbBSResultBuffer; overload;
    procedure ExtractAllFiles(const aFolderName: string;
      aOverwriteCurrentFiles: Boolean);
    procedure ReleaseFileDataCompat(fileDataResult: TwbBSResultBuffer);
    procedure ExtractFile(const aFilePath, aSaveAs: string);
    procedure IterateFilesCompat(aProc: TBSFileIterationProcCompat;
      aContext: Pointer = nil);
    function FileExists(const aFilePath: string): Boolean;
    procedure ResourceListCompat(const aEntryResultList: TwbBSEntryList;
      aFolder: string = '');
    procedure ResolveHashCompat(const aHash: UInt64;
      const aEntryResultList: TwbBSEntryList);
    procedure Close;

    property FileName: string read fFileName;
    property ArchiveType: TBSArchiveType read fType;
    property Version: Cardinal read fVersion;
    property FormatName: string read GetArchiveFormatName;
    property FileCount: Cardinal read GetFileCount;
    property ArchiveFlags: Cardinal read fHeaderTES4.Flags
      write SetArchiveFlags;
    property FileFlags: Cardinal read fHeaderTES4.FileFlags
      write fHeaderTES4.FileFlags;
    property Compress: Boolean read fCompress write fCompress;
    property ShareData: Boolean read fShareData write fShareData;
    property DDSInfoProc: TBSFileDDSInfoProcCompat read fDDSInfoProc
      write fDDSInfoProc;
    property DDSInfoProcContext: Pointer read fDDSInfoProcContext
      write fDDSInfoProcContext;
  end;

function SplitDirName(const aFilePath: string; var Dir, Name: string): Integer;
function SplitNameExt(const aFilePath: string; var Name, Ext: string): Integer;
function CreateHashTES3(const aFilePath: string): UInt64;
function CreateHashTES4(const aFilePath: string): UInt64; overload;
function CreateHashFO4(const aFilePath: string): Cardinal;

implementation

uses
  TypInfo,
  zlibEx,
  lz4io;

const
  TBSArchiveFormatName: array [TBSArchiveType] of string = ('None', 'Morrowind',
    'Oblivion', 'Fallout 3, New Vegas, Skyrim LE', 'Skyrim Special Edition',
    'Fallout 4 General', 'Fallout 4 DDS');

  MAGIC_TES3: TMagic4 = #0#1#0#0;
  MAGIC_BSA: TMagic4 = 'BSA'#0;
  MAGIC_BTDX: TMagic4 = 'BTDX';
  MAGIC_GNRL: TMagic4 = 'GNRL';
  MAGIC_DX10: TMagic4 = 'DX10';
  MAGIC_DDS: TMagic4 = 'DDS ';
  MAGIC_DXT1: TMagic4 = 'DXT1';
  MAGIC_DXT3: TMagic4 = 'DXT3';
  MAGIC_DXT5: TMagic4 = 'DXT5';
  MAGIC_ATI1: TMagic4 = 'ATI1';
  MAGIC_ATI2: TMagic4 = 'ATI2';
  MAGIC_BC4S: TMagic4 = 'BC4S';
  MAGIC_BC4U: TMagic4 = 'BC4U';
  MAGIC_BC5S: TMagic4 = 'BC5S';
  MAGIC_BC5U: TMagic4 = 'BC5U';

  iFileFO4Unknown = $00100100;
  iFileFO4Tail = $BAADF00D;

  { https://github.com/jonwd7/bae/blob/master/src/bsa.h }

  // header versions
  HEADER_VERSION_TES4 = $67; // Oblivion
  HEADER_VERSION_FO3 = $68; // FO3, FNV, TES5
  HEADER_VERSION_SSE = $69; // SSE
  HEADER_VERSION_FO4 = $01; // FO4

  // archive flags
  ARCHIVE_PATHNAMES = $0001; // Whether the BSA has names for paths
  ARCHIVE_FILENAMES = $0002; // Whether the BSA has names for files
  ARCHIVE_COMPRESS = $0004;
  // Whether the files are compressed in archive (invert file's compression flag)
  ARCHIVE_RETAINDIR = $0008;
  ARCHIVE_RETAINNAME = $0010;
  ARCHIVE_RETAINFOFF = $0020;
  ARCHIVE_XBOX360 = $0040;
  ARCHIVE_STARTUPSTR = $0080;
  ARCHIVE_EMBEDNAME = $0100; // Whether the name is prefixed to the data
  ARCHIVE_XMEM = $0200;
  ARCHIVE_UNKNOWN10 = $0400;

  // file flags
  FILE_NIF = $0001;
  FILE_DDS = $0002;
  FILE_XML = $0004;
  FILE_WAV = $0008;
  FILE_MP3 = $0010;
  FILE_TXT = $0020; // TXT, HTML, BAT, SCC
  FILE_SPT = $0040;
  FILE_FNT = $0080; // TEX, FNT
  FILE_MISC = $0100; // CTL and others

  FILE_SIZE_COMPRESS = $40000000; // Whether the file is compressed

  DDSD_CAPS = $00000001;
  DDSD_HEIGHT = $00000002;
  DDSD_WIDTH = $00000004;
  DDSD_PITCH = $00000008;
  DDSD_PIXELFORMAT = $00001000;
  DDSD_MIPMAPCOUNT = $00020000;
  DDSD_LINEARSIZE = $00080000;
  DDSD_DEPTH = $00800000;
  DDSCAPS_COMPLEX = $00000008;
  DDSCAPS_TEXTURE = $00001000;
  DDSCAPS_MIPMAP = $00400000;
  DDSCAPS2_CUBEMAP = $00000200;
  DDSCAPS2_POSITIVEX = $00000400;
  DDSCAPS2_NEGATIVEX = $00000800;
  DDSCAPS2_POSITIVEY = $00001000;
  DDSCAPS2_NEGATIVEY = $00002000;
  DDSCAPS2_POSITIVEZ = $00004000;
  DDSCAPS2_NEGATIVEZ = $00008000;
  DDSCAPS2_VOLUME = $00200000;
  DDPF_ALPHAPIXELS = $00000001;
  DDPF_ALPHA = $00000002;
  DDPF_FOURCC = $00000004;
  DDPF_RGB = $00000040;
  DDPF_YUV = $00000200;
  DDPF_LUMINANCE = $00020000;

  // DX10
  DDS_DIMENSION_TEXTURE2D = $00000003;
  DDS_RESOURCE_MISC_TEXTURECUBE = $00000004;

  crc32table: array [0 .. 255] of Cardinal = ($00000000, $77073096, $EE0E612C,
    $990951BA, $076DC419, $706AF48F, $E963A535, $9E6495A3, $0EDB8832, $79DCB8A4,
    $E0D5E91E, $97D2D988, $09B64C2B, $7EB17CBD, $E7B82D07, $90BF1D91, $1DB71064,
    $6AB020F2, $F3B97148, $84BE41DE, $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7,
    $136C9856, $646BA8C0, $FD62F97A, $8A65C9EC, $14015C4F, $63066CD9, $FA0F3D63,
    $8D080DF5, $3B6E20C8, $4C69105E, $D56041E4, $A2677172, $3C03E4D1, $4B04D447,
    $D20D85FD, $A50AB56B, $35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940, $32D86CE3,
    $45DF5C75, $DCD60DCF, $ABD13D59, $26D930AC, $51DE003A, $C8D75180, $BFD06116,
    $21B4F4B5, $56B3C423, $CFBA9599, $B8BDA50F, $2802B89E, $5F058808, $C60CD9B2,
    $B10BE924, $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D, $76DC4190, $01DB7106,
    $98D220BC, $EFD5102A, $71B18589, $06B6B51F, $9FBFE4A5, $E8B8D433, $7807C9A2,
    $0F00F934, $9609A88E, $E10E9818, $7F6A0DBB, $086D3D2D, $91646C97, $E6635C01,
    $6B6B51F4, $1C6C6162, $856530D8, $F262004E, $6C0695ED, $1B01A57B, $8208F4C1,
    $F50FC457, $65B0D9C6, $12B7E950, $8BBEB8EA, $FCB9887C, $62DD1DDF, $15DA2D49,
    $8CD37CF3, $FBD44C65, $4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2, $4ADFA541,
    $3DD895D7, $A4D1C46D, $D3D6F4FB, $4369E96A, $346ED9FC, $AD678846, $DA60B8D0,
    $44042D73, $33031DE5, $AA0A4C5F, $DD0D7CC9, $5005713C, $270241AA, $BE0B1010,
    $C90C2086, $5768B525, $206F85B3, $B966D409, $CE61E49F, $5EDEF90E, $29D9C998,
    $B0D09822, $C7D7A8B4, $59B33D17, $2EB40D81, $B7BD5C3B, $C0BA6CAD, $EDB88320,
    $9ABFB3B6, $03B6E20C, $74B1D29A, $EAD54739, $9DD277AF, $04DB2615, $73DC1683,
    $E3630B12, $94643B84, $0D6D6A3E, $7A6A5AA8, $E40ECF0B, $9309FF9D, $0A00AE27,
    $7D079EB1, $F00F9344, $8708A3D2, $1E01F268, $6906C2FE, $F762575D, $806567CB,
    $196C3671, $6E6B06E7, $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC, $F9B9DF6F,
    $8EBEEFF9, $17B7BE43, $60B08ED5, $D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252,
    $D1BB67F1, $A6BC5767, $3FB506DD, $48B2364B, $D80D2BDA, $AF0A1B4C, $36034AF6,
    $41047A60, $DF60EFC3, $A867DF55, $316E8EEF, $4669BE79, $CB61B38C, $BC66831A,
    $256FD2A0, $5268E236, $CC0C7795, $BB0B4703, $220216B9, $5505262F, $C5BA3BBE,
    $B2BD0B28, $2BB45A92, $5CB36A04, $C2D7FFA7, $B5D0CF31, $2CD99E8B, $5BDEAE1D,
    $9B64C2B0, $EC63F226, $756AA39C, $026D930A, $9C0906A9, $EB0E363F, $72076785,
    $05005713, $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38, $92D28E9B, $E5D5BE0D,
    $7CDCEFB7, $0BDBDF21, $86D3D2D4, $F1D4E242, $68DDB3F8, $1FDA836E, $81BE16CD,
    $F6B9265B, $6FB077E1, $18B74777, $88085AE6, $FF0F6A70, $66063BCA, $11010B5C,
    $8F659EFF, $F862AE69, $616BFFD3, $166CCF45, $A00AE278, $D70DD2EE, $4E048354,
    $3903B3C2, $A7672661, $D06016F7, $4969474D, $3E6E77DB, $AED16A4A, $D9D65ADC,
    $40DF0B66, $37D83BF0, $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9, $BDBDF21C,
    $CABAC28A, $53B39330, $24B4A3A6, $BAD03605, $CDD70693, $54DE5729, $23D967BF,
    $B3667A2E, $C4614AB8, $5D681B02, $2A6F2B94, $B40BBE37, $C30C8EA1, $5A05DF1B,
    $2D02EF8D);

type
  TPreallocatedMemoryStream = class(TCustomMemoryStream)
  public
    constructor Create(Ptr: Pointer; Size: Int64);
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

constructor TPreallocatedMemoryStream.Create(Ptr: Pointer; Size: Int64);
begin
  inherited Create;
  SetPointer(Ptr, Size);
end;

function TPreallocatedMemoryStream.Write(const Buffer; Count: Integer): Longint;
begin
  Result := Size - Position;
  if Result > Count then
    Result := Count;
  System.Move(Buffer, Pointer(PByte(Memory) + Position)^, Result);
  Seek(Result, soCurrent);
end;

function Magic2Int(aMagic: TMagic4): Cardinal; inline;
begin
  Result := PCardinal(@aMagic)^;
end;

function Int2Magic(aInt: Cardinal): TMagic4; inline;
begin
  Result := PMagic4(@aInt)^;
end;

function String2Magic(const aStr: string): TMagic4;
begin
  Result := #0#0#0#0;
  if Length(aStr) > 0 then
    Result[0] := AnsiChar(aStr[1]);
  if Length(aStr) > 1 then
    Result[1] := AnsiChar(aStr[2]);
  if Length(aStr) > 2 then
    Result[2] := AnsiChar(aStr[3]);
  if Length(aStr) > 3 then
    Result[3] := AnsiChar(aStr[4]);
end;

function LowerByte(ch: AnsiChar): Byte; inline;
begin
  case ch of
    'A' .. 'Z':
      Result := Byte(Ord(ch) + Ord('a') - Ord('A'));
  else
    Result := Byte(ch);
  end;
end;

function LastCharPos(const s: string; const Chr: char): Integer; inline;
begin
  for Result := Length(s) downto 1 do
    if s[Result] = Chr then
      Exit;
  Result := 0;
end;

function Str2MagicInt(const s: string): Cardinal;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(s) do
  begin
    PByte(PByte(@Result) + i - 1)^ := LowerByte(AnsiChar(s[i]));
    if i = 4 then
      Break;
  end;
end;

function SplitDirName(const aFilePath: string; var Dir, Name: string): Integer;
begin
  Result := LastCharPos(aFilePath, '\');
  if Result = 0 then
    Result := LastCharPos(aFilePath, '/');
  Dir := Copy(aFilePath, 1, Pred(Result));
  Name := Copy(aFilePath, Succ(Result), Length(aFilePath) - Result);
end;

function SplitNameExt(const aFilePath: string; var Name, Ext: string): Integer;
begin
  Result := LastCharPos(aFilePath, '.');
  if Result <> 0 then
  begin
    Name := Copy(aFilePath, 1, Pred(Result));
    Ext := Copy(aFilePath, Result, Length(aFilePath) - Result + 2);
  end
  else
  begin
    Name := aFilePath;
    Ext := '';
  end;
end;

function CreateHashTES3(const aFilePath: string): UInt64;
var
  s: AnsiString;
  i, l: Integer;
  sum, off, temp, n: Cardinal;
begin
  s := AnsiString(aFilePath);
  l := Length(s) shr 1;

  sum := 0;
  off := 0;
  for i := 1 to l do
  begin
    temp := Cardinal(LowerByte(s[i])) shl (off and $1F);
    sum := sum xor temp;
    off := off + 8;
  end;
  Result := UInt64(sum) shl 32;

  sum := 0;
  off := 0;
  for i := l + 1 to Length(s) do
  begin
    temp := Cardinal(LowerByte(s[i])) shl (off and $1F);
    sum := sum xor temp;
    n := temp and $1F;
    sum := (sum shr n) or (sum shl (32 - n));
    off := off + 8;
  end;
  Result := Result or sum;
end;

function CreateHashTES4(const aName, aExt: string): UInt64; overload;
var
  i, l: Integer;
  Hash: Cardinal;
  Ext: array [0 .. 3] of Byte;
  s, e: AnsiString;
begin
  Result := 0;
  s := AnsiString(aName);
  e := AnsiString(aExt);

  l := Length(s);
  if l = 0 then
    Exit;

  Result := LowerByte(s[l]);
  if l > 2 then
    Result := Result or (Cardinal(LowerByte(s[l - 1])) shl 8);
  Result := Result or (l shl 16);
  Result := Result or (Cardinal(LowerByte(s[1])) shl 24);

  PCardinal(@Ext)^ := 0;
  for i := 1 to Length(e) do
  begin
    Ext[i - 1] := LowerByte(e[i]);
    if i = 4 then
      Break;
  end;

  case PCardinal(@Ext)^ of
    $00666B2E:
      Result := Result or $80; // .kf
    $66696E2E:
      Result := Result or $8000; // .nif
    $7364642E:
      Result := Result or $8080; // .dds
    $7661772E:
      Result := Result or $80000000; // .wav
  end;

  Hash := 0;
  for i := 2 to l - 2 do
    Hash := LowerByte(s[i]) + (Hash shl 6) + (Hash shl 16) - Hash;
  Result := Result + UInt64(Hash) shl 32;

  Hash := 0;
  for i := 1 to Length(e) do
    Hash := LowerByte(e[i]) + (Hash shl 6) + (Hash shl 16) - Hash;
  Result := Result + UInt64(Hash) shl 32;
end;

function CreateHashTES4(const aFilePath: string): UInt64; overload;
var
  fname, fext: string;
begin
  SplitNameExt(aFilePath, fname, fext);
  Result := CreateHashTES4(fname, fext);
end;

function CreateHashFO4(const aFilePath: string): Cardinal;
var
  i: Integer;
  s: AnsiString;
  c: AnsiChar;
begin
  Result := 0;
  s := AnsiString(aFilePath);
  for i := 1 to Length(s) do
  begin
    c := s[i];
    if Byte(c) > 127 then
      Continue;
    if c = '/' then
      c := '\';
    Result := (Result shr 8) xor crc32table[(Result xor LowerByte(c)) and $FF];
  end;
end;

function TwbBSFileTES4.Compressed(bsa: TwbBSArchive): Boolean;
begin
  Result := (bsa.ArchiveFlags and ARCHIVE_COMPRESS <> 0)
    xor (Size and FILE_SIZE_COMPRESS <> 0);
end;

function TwbBSFileTES4.RawSize: Cardinal;
begin
  Result := Size and not FILE_SIZE_COMPRESS;
end;

function TwbBSFileFO4.DXGIFormatName: string;
begin
  Result := GetEnumName(TypeInfo(TDXGI), Integer(dxgiFormat));
end;

{ TwbBSArchive }

constructor TwbBSArchive.Create;
begin
  fType := baNone;
  fMaxChunkCount := 4;
  fSingleMipChunkX := 512;
  fSingleMipChunkY := 512;
  Sync := TSimpleRWSync.Create;
end;

destructor TwbBSArchive.Destroy;
begin
  if fStates * [stReading, stWriting] <> [] then
    Close;
end;

function TwbBSArchive.GetArchiveFormatName: string;
begin
  Result := TBSArchiveFormatName[fType];
end;

function TwbBSArchive.GetFileCount: Cardinal;
begin
  case fType of
    baTES3:
      Result := fHeaderTES3.FileCount;
    baTES4, baFO3, baSSE:
      Result := fHeaderTES4.FileCount;
    baFO4, baFO4dds:
      // because we use fHeaderFO4.FileCount as the current index in new archives
      Result := Length(fFilesFO4);
  else
    Result := 0;
  end;
end;

procedure TwbBSArchive.SetArchiveFlags(aFlags: Cardinal);
begin
  if not(fType in [baTES4, baFO3, baSSE]) then
    raise Exception.Create
      ('Archive flags are not supported for this archive type');

  fHeaderTES4.Flags := aFlags;

  // force compression flag if needed
  if fCompress then
    fHeaderTES4.Flags := fHeaderTES4.Flags or ARCHIVE_COMPRESS;
end;

function TwbBSArchive.FindFileRecordTES3(const aFilePath: string;
  var aFileIdx: Integer): Boolean;
var
  h: UInt64;
  i: Integer;
begin
  h := CreateHashTES3(aFilePath);

  Result := False;
  for i := Low(fFilesTES3) to High(fFilesTES3) do
    if fFilesTES3[i].Hash = h then
    begin
      aFileIdx := i;
      Result := True;
      Exit;
    end;
end;

function TwbBSArchive.FindFileRecordTES4(const aFilePath: string;
  var aFolderIdx, aFileIdx: Integer): Boolean;
var
  fdir, fname, Name, Ext: string;
  h: UInt64;
  i, j: Integer;
begin
  if SplitDirName(aFilePath, fdir, fname) = 0 then
    Exit(False);

  Result := False;
  h := CreateHashTES4(fdir, '');
  for i := Low(fFoldersTES4) to High(fFoldersTES4) do
  begin
    if h <> fFoldersTES4[i].Hash then
      // since table is sorted by hash, we can abort when our hash is lesser
      if h < fFoldersTES4[i].Hash then
        Exit
      else
        Continue;

    SplitNameExt(fname, name, Ext);
    h := CreateHashTES4(name, Ext);
    for j := Low(fFoldersTES4[i].Files) to High(fFoldersTES4[i].Files) do
    begin
      if h <> fFoldersTES4[i].Files[j].Hash then
        if h < fFoldersTES4[i].Files[j].Hash then
          Exit
        else
          Continue;

      Result := True;
      aFolderIdx := i;
      aFileIdx := j;
      Exit;
    end;
  end;
end;

function TwbBSArchive.FindFileRecordFO4(const aFilePath: string;
  var aFileIdx: Integer): Boolean;
var
  fdir, fname, Name, Ext: string;
  hdir, hfile: Cardinal;
  hext: TMagic4;
  i: Integer;
begin
  if SplitDirName(aFilePath, fdir, fname) = 0 then
    Exit(False);

  SplitNameExt(fname, name, Ext);
  hdir := CreateHashFO4(fdir);
  hfile := CreateHashFO4(name);
  if Copy(Ext, 1, 1) = '.' then
    Delete(Ext, 1, 1);
  hext := String2Magic(LowerCase(Ext));

  Result := False;
  for i := Low(fFilesFO4) to High(fFilesFO4) do
    if (fFilesFO4[i].DirHash = hdir) and (fFilesFO4[i].NameHash = hfile) and
      (fFilesFO4[i].Ext = hext) then
    begin
      aFileIdx := i;
      Result := True;
      Exit;
    end;
end;

function TwbBSArchive.FindFileRecord(const aFilePath: string): Pointer;
var
  i, j: Integer;
begin
  Result := nil;

  case fType of
    baTES3:
      if FindFileRecordTES3(aFilePath, i) then
        Result := @fFilesTES3[i];
    baTES4, baFO3, baSSE:
      if FindFileRecordTES4(aFilePath, i, j) then
        Result := @fFoldersTES4[i].Files[j];
    baFO4, baFO4dds:
      if FindFileRecordFO4(aFilePath, i) then
        Result := @fFilesFO4[i];
  end;
end;

function TwbBSArchive.GetDDSMipChunkNum(var aDDSInfo: TDDSInfo): Integer;
var
  w, h: Integer;
begin
  w := aDDSInfo.Width;
  h := aDDSInfo.Height;
  Result := 1;
  while (Result < aDDSInfo.MipMaps) and (Result < fMaxChunkCount) and
    (w >= fSingleMipChunkX) and (h >= fSingleMipChunkY) do
  begin
    Inc(Result);
    w := w div 2;
    h := h div 2;
  end;
end;

function TwbBSArchive.CalcDataHash(aData: Pointer; aLen: Cardinal)
  : TPackedDataHash;
var
  fMD5: TMD5Alg;
begin
  fMD5.Init(@fMD5);
  fMD5.Update(@fMD5, aData, aLen);
  fMD5.Done(@fMD5, @Result);
end;

function TwbBSArchive.FindPackedData(aSize: Cardinal; aHash: TPackedDataHash;
  aFileRecord: Pointer): Boolean;
var
  i: Integer;
begin
  Result := False;

  if not fShareData then
    Exit;

  for i := 0 to Pred(fPackedDataCount) do
    if (aSize = fPackedData[i].Size) and
      CompareMem(@aHash, @fPackedData[i].Hash, SizeOf(aHash)) then
    begin
      case fType of
        baTES3:
          begin
            PwbBSFileTES3(aFileRecord).Size :=
              PwbBSFileTES3(fPackedData[i].FileRecord).Size;
            PwbBSFileTES3(aFileRecord).Offset :=
              PwbBSFileTES3(fPackedData[i].FileRecord).Offset;
          end;
        baTES4, baFO3, baSSE:
          begin
            PwbBSFileTES4(aFileRecord).Size :=
              PwbBSFileTES4(fPackedData[i].FileRecord).Size;
            PwbBSFileTES4(aFileRecord).Offset :=
              PwbBSFileTES4(fPackedData[i].FileRecord).Offset;
          end;
        baFO4:
          begin
            PwbBSFileFO4(aFileRecord).Size :=
              PwbBSFileFO4(fPackedData[i].FileRecord).Size;
            PwbBSFileFO4(aFileRecord).PackedSize :=
              PwbBSFileFO4(fPackedData[i].FileRecord).PackedSize;
            PwbBSFileFO4(aFileRecord).Offset :=
              PwbBSFileFO4(fPackedData[i].FileRecord).Offset;
          end;
        baFO4dds:
          begin
            PwbBSTexChunkRec(aFileRecord).Size :=
              PwbBSTexChunkRec(fPackedData[i].FileRecord).Size;
            PwbBSTexChunkRec(aFileRecord).PackedSize :=
              PwbBSTexChunkRec(fPackedData[i].FileRecord).PackedSize;
            PwbBSTexChunkRec(aFileRecord).Offset :=
              PwbBSTexChunkRec(fPackedData[i].FileRecord).Offset;
          end;
      end;
      Result := True;
      Exit;
    end;
end;

procedure TwbBSArchive.AddPackedData(aSize: Cardinal; aHash: TPackedDataHash;
  aFileRecord: Pointer);
begin
  if not fShareData then
    Exit;

  if fPackedDataCount = Length(fPackedData) then
    if Length(fPackedData) = 0 then
      SetLength(fPackedData, 2048)
    else
      SetLength(fPackedData, Length(fPackedData) * 2);

  fPackedData[fPackedDataCount].Size := aSize;
  fPackedData[fPackedDataCount].Hash := aHash;
  fPackedData[fPackedDataCount].FileRecord := aFileRecord;
  Inc(fPackedDataCount);
end;

procedure TwbBSArchive.LoadFromFile(const aFilePath: string);
var
  i, j: Integer;
begin
  if fStates * [stReading, stWriting] <> [] then
    Close;

  fStream := TwbReadOnlyCachedFileStream.Create(aFilePath,
    fmOpenRead or fmShareDenyWrite);

  // magic
  fMagic := Int2Magic(fStream.ReadCardinal);
  if fMagic = MAGIC_TES3 then
    fType := baTES3
  else if fMagic = MAGIC_BSA then
    fType := baTES4
  else if fMagic = MAGIC_BTDX then
    fType := baFO4
  else
    raise Exception.Create('Unknown archive format');

  // archive version except Morrowind
  if fType <> baTES3 then
  begin
    fVersion := fStream.ReadCardinal;
    case fVersion of
      HEADER_VERSION_TES4:
        fType := baTES4;
      HEADER_VERSION_FO3:
        fType := baFO3;
      HEADER_VERSION_SSE:
        fType := baSSE;
      HEADER_VERSION_FO4:
        fType := baFO4;
    else
      raise Exception.Create('Unknown archive version 0x' +
        IntToHex(fVersion, 8));
    end;
  end;

  case fType of
    // --------------------------------------------------
    // Morrowind
    baTES3:
      begin
        // read header
        fStream.ReadBuffer(fHeaderTES3, SizeOf(fHeaderTES3));
        SetLength(fFilesTES3, fHeaderTES3.FileCount);
        for i := Low(fFilesTES3) to High(fFilesTES3) do
        begin
          fFilesTES3[i].Size := fStream.ReadCardinal;
          fFilesTES3[i].Offset := fStream.ReadCardinal;
        end;
        // skip name offsets
        fStream.Position := fStream.Position + 4 * fHeaderTES3.FileCount;
        // read names
        for i := Low(fFilesTES3) to High(fFilesTES3) do
          fFilesTES3[i].Name := fStream.ReadStringTerm;
        // read hashes
        for i := Low(fFilesTES3) to High(fFilesTES3) do
          fFilesTES3[i].Hash := fStream.ReadUInt64;
        // remember binary data offset since stored files offsets are relative
        fDataOffset := fStream.Position;
      end;

    // --------------------------------------------------
    // Fallout 4
    baFO4:
      begin
        // read header
        fStream.ReadBuffer(fHeaderFO4, SizeOf(fHeaderFO4));

        // read GNRL files
        if fHeaderFO4.Magic = MAGIC_GNRL then
        begin
          SetLength(fFilesFO4, fHeaderFO4.FileCount);
          for i := Low(fFilesFO4) to High(fFilesFO4) do
          begin
            fFilesFO4[i].NameHash := fStream.ReadCardinal;
            fFilesFO4[i].Ext := Int2Magic(fStream.ReadCardinal);
            fFilesFO4[i].DirHash := fStream.ReadCardinal;
            fFilesFO4[i].Unknown := fStream.ReadCardinal;
            fFilesFO4[i].Offset := fStream.ReadInt64;
            fFilesFO4[i].PackedSize := fStream.ReadCardinal;
            fFilesFO4[i].Size := fStream.ReadCardinal;
            fStream.ReadCardinal; // BAADF00D
          end;
        end
        // read DX10 textures
        else if fHeaderFO4.Magic = MAGIC_DX10 then
        begin
          fType := baFO4dds;
          SetLength(fFilesFO4, fHeaderFO4.FileCount);
          for i := Low(fFilesFO4) to High(fFilesFO4) do
          begin
            fFilesFO4[i].NameHash := fStream.ReadCardinal;
            fFilesFO4[i].Ext := Int2Magic(fStream.ReadCardinal);
            fFilesFO4[i].DirHash := fStream.ReadCardinal;
            fFilesFO4[i].UnknownTex := fStream.ReadByte;
            SetLength(fFilesFO4[i].TexChunks, fStream.ReadByte);
            fStream.ReadWord; // skip chunkHeaderSize, always 24
            // fFilesFO4[i].ChunkHeaderSize := fStream.ReadWord;
            fFilesFO4[i].Height := fStream.ReadWord;
            fFilesFO4[i].Width := fStream.ReadWord;
            fFilesFO4[i].NumMips := fStream.ReadByte;
            fFilesFO4[i].dxgiFormat := fStream.ReadByte;
            fFilesFO4[i].CubeMaps := fStream.ReadWord;
            for j := Low(fFilesFO4[i].TexChunks)
              to High(fFilesFO4[i].TexChunks) do
              with fFilesFO4[i].TexChunks[j] do
              begin
                Offset := fStream.ReadInt64;
                PackedSize := fStream.ReadCardinal;
                Size := fStream.ReadCardinal;
                StartMip := fStream.ReadWord;
                EndMip := fStream.ReadWord;
                fStream.ReadCardinal; // skip BAADF00D
              end;
          end;
        end
        else
          raise Exception.Create('Unknown BA2 archive type');

        // read file names
        fStream.Position := fHeaderFO4.FileTableOffset;
        for i := Low(fFilesFO4) to High(fFilesFO4) do
          fFilesFO4[i].Name := StringReplace(fStream.ReadStringLen16, '/', '\',
            [rfReplaceAll]);
      end;

    // --------------------------------------------------
    // Oblivion, Fallout 3, New Vegas, Skyrim, Skyrim SE
    baTES4, baFO3, baSSE:
      begin
        // read header
        fStream.ReadBuffer(fHeaderTES4, SizeOf(fHeaderTES4));
        fStream.Position := fHeaderTES4.FoldersOffset;

        // read folder records
        SetLength(fFoldersTES4, fHeaderTES4.FolderCount);
        for i := Low(fFoldersTES4) to High(fFoldersTES4) do
        begin
          fFoldersTES4[i].Hash := fStream.ReadUInt64;
          fFoldersTES4[i].FileCount := fStream.ReadCardinal;
          if fType = baSSE then
          begin
            fFoldersTES4[i].Unk32 := fStream.ReadCardinal;
            fFoldersTES4[i].Offset := fStream.ReadInt64;
          end
          else
            fFoldersTES4[i].Offset := fStream.ReadCardinal;
        end;

        // read folder names and file records
        for i := Low(fFoldersTES4) to High(fFoldersTES4) do
        begin
          fFoldersTES4[i].Name := fStream.ReadStringLen;
          SetLength(fFoldersTES4[i].Files, fFoldersTES4[i].FileCount);
          for j := Low(fFoldersTES4[i].Files) to High(fFoldersTES4[i].Files) do
          begin
            fFoldersTES4[i].Files[j].Hash := fStream.ReadUInt64;
            fFoldersTES4[i].Files[j].Size := fStream.ReadCardinal;
            fFoldersTES4[i].Files[j].Offset := fStream.ReadCardinal;
          end;
        end;

        // read file names
        for i := Low(fFoldersTES4) to High(fFoldersTES4) do
          for j := Low(fFoldersTES4[i].Files) to High(fFoldersTES4[i].Files) do
            fFoldersTES4[i].Files[j].Name := fStream.ReadStringTerm;

      end;

  end;

  fFileName := aFilePath;
  Include(fStates, stReading);
end;

type
  THashPair = record
    DirHash, FileHash: UInt64;
  end;

  PHashPair = ^THashPair;

function HashPairSort(List: TStringList; Index1, Index2: Integer): Integer;
var
  h1, h2: PHashPair;
begin
  h1 := PHashPair(List.Objects[Index1]);
  h2 := PHashPair(List.Objects[Index2]);
  if h1.DirHash < h2.DirHash then
    Result := -1
  else if h1.DirHash > h2.DirHash then
    Result := 1
  else if h1.FileHash < h2.FileHash then
    Result := -1
  else if h1.FileHash > h2.FileHash then
    Result := 1
  else
    Result := 0;
end;

function AlphabeticalSort(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := CompareStr(List[Index1], List[Index2]);
end;

procedure TwbBSArchive.CreateArchiveCompat(const aFilePath: string;
  aType: TBSArchiveType; aFilesList: TwbBSEntryList = nil);
var
  HashPairs: array of THashPair;
  h: PHashPair;
  hdir: UInt64;
  s, fdir, fname, fext: string;
  i, len, folderidx, fileidx: Integer;
  Buffer: TBytes;
  ddsinfo: TDDSInfo;
begin
  if stReading in fStates then
    Close;

  if stWriting in fStates then
    raise Exception.Create('Archive is already being created');

  case aType of
    baTES3:
      begin
        fMagic := MAGIC_TES3;
      end;
    baTES4:
      begin
        fVersion := HEADER_VERSION_TES4;
        fMagic := MAGIC_BSA;
        fHeaderTES4.Flags := ARCHIVE_PATHNAMES or ARCHIVE_FILENAMES or
          ARCHIVE_EMBEDNAME or ARCHIVE_XMEM or ARCHIVE_UNKNOWN10;
        fHeaderTES4.FileFlags := 0;
        fHeaderTES4.FoldersOffset := SizeOf(fMagic) + SizeOf(fVersion) +
          SizeOf(fHeaderTES4);
      end;
    baFO3:
      begin
        fVersion := HEADER_VERSION_FO3;
        fMagic := MAGIC_BSA;
        fHeaderTES4.Flags := ARCHIVE_PATHNAMES or ARCHIVE_FILENAMES;
        fHeaderTES4.FileFlags := 0;
        fHeaderTES4.FoldersOffset := SizeOf(fMagic) + SizeOf(fVersion) +
          SizeOf(fHeaderTES4);
      end;
    baSSE:
      begin
        fVersion := HEADER_VERSION_SSE;
        fMagic := MAGIC_BSA;
        fHeaderTES4.Flags := ARCHIVE_PATHNAMES or ARCHIVE_FILENAMES;
        fHeaderTES4.FileFlags := 0;
        fHeaderTES4.FoldersOffset := SizeOf(fMagic) + SizeOf(fVersion) +
          SizeOf(fHeaderTES4);
      end;
    baFO4:
      begin
        fMagic := MAGIC_BTDX;
        fHeaderFO4.Magic := MAGIC_GNRL;
        fVersion := HEADER_VERSION_FO4;
      end;
    baFO4dds:
      begin
        fMagic := MAGIC_BTDX;
        fHeaderFO4.Magic := MAGIC_DX10;
        fVersion := HEADER_VERSION_FO4;
      end;
  else
    raise Exception.Create('Unsupported archive type');
  end;

  fType := aType;

  if fType in [baTES3] then
  begin
    if not Assigned(aFilesList) or (aFilesList.Count = 0) then
      raise Exception.Create('Archive requires predefined files list');

    // sort files by hashes
    SetLength(HashPairs, aFilesList.Count);
    for i := 0 to Pred(aFilesList.Count) do
    begin
      h := @HashPairs[i];
      h.FileHash := CreateHashTES3(aFilesList[i]);
      aFilesList.Objects[i] := Pointer(h);
    end;
    aFilesList.CustomSort(HashPairSort);

    // create file records and calculate total names length
    SetLength(fFilesTES3, aFilesList.Count);
    len := 0;
    for i := 0 to Pred(aFilesList.Count) do
    begin
      fFilesTES3[i].Hash := PHashPair(aFilesList.Objects[i]).FileHash;
      fFilesTES3[i].Name := LowerCase(aFilesList[i]);
      Inc(len, Length(fFilesTES3[i].Name) + 1); // include terminator
    end;

    // offset to hash table
    fDataOffset := SizeOf(fMagic) + SizeOf(fHeaderTES3) + 8 * Length(fFilesTES3)
      + // File sizes/offsets
      4 * Length(fFilesTES3) + // Archive directory/name offsets
      len; // Filename records

    // stored as minus 12 (for header size)
    fHeaderTES3.HashOffset := fDataOffset - 12;
    fHeaderTES3.FileCount := aFilesList.Count;

    // offset to files data
    fDataOffset := fDataOffset + 8 * Length(fFilesTES3); // Hash table

    // files are stored alphabetically in the data section in vanilla archives
    // not really needed but whatever
    aFilesList.CustomSort(AlphabeticalSort);
  end

  else if fType in [baTES4, baFO3, baSSE] then
  begin
    if not Assigned(aFilesList) or (aFilesList.Count = 0) then
      raise Exception.Create('Archive requires predefined files list');

    fHeaderTES4.FolderNamesLength := 0;
    fHeaderTES4.FileNamesLength := 0;

    // dirs and files must be sorted by their hashes
    SetLength(HashPairs, aFilesList.Count);
    for i := 0 to Pred(aFilesList.Count) do
    begin
      h := @HashPairs[i];
      if SplitDirName(aFilesList[i], fdir, fname) = 0 then
        raise Exception.Create('File is missing the folder part: ' +
          aFilesList[i]);

      // calculate hashes
      h.DirHash := CreateHashTES4(fdir, '');
      SplitNameExt(fname, s, fext);
      h.FileHash := CreateHashTES4(s, fext);
      aFilesList.Objects[i] := Pointer(h);

      // determine file flags
      fext := LowerCase(fext);
      with fHeaderTES4 do
        if fext = '.nif' then
          FileFlags := FileFlags or FILE_NIF
        else if fext = '.dds' then
          FileFlags := FileFlags or FILE_DDS
        else if fext = '.xml' then
          FileFlags := FileFlags or FILE_XML or FILE_MISC
        else if fext = '.wav' then
          FileFlags := FileFlags or FILE_WAV
        else if fext = '.fuz' then
          FileFlags := FileFlags or FILE_WAV
        else if fext = '.mp3' then
          FileFlags := FileFlags or FILE_MP3
        else if fext = '.ogg' then
          FileFlags := FileFlags or FILE_MP3
        else if fext = '.txt' then
          FileFlags := FileFlags or FILE_TXT
        else if fext = '.htm' then
          FileFlags := FileFlags or FILE_TXT
        else if fext = '.bat' then
          FileFlags := FileFlags or FILE_TXT
        else if fext = '.scc' then
          FileFlags := FileFlags or FILE_TXT
        else if fext = '.spt' then
          FileFlags := FileFlags or FILE_SPT
        else if fext = '.fnt' then
          FileFlags := FileFlags or FILE_FNT
        else if fext = '.tex' then
          FileFlags := FileFlags or FILE_FNT
        else
          FileFlags := FileFlags or FILE_MISC;
    end;

    // sort by hashes
    aFilesList.CustomSort(HashPairSort);

    // create folder and file records
    fHeaderTES4.FileCount := 0;
    hdir := 0;
    folderidx := -1;
    fileidx := 0;
    for i := 0 to Pred(aFilesList.Count) do
    begin
      SplitDirName(aFilesList[i], fdir, fname);
      h := Pointer(aFilesList.Objects[i]);
      // new folder
      if h.DirHash <> hdir then
      begin
        Inc(folderidx);
        fileidx := 0;
        hdir := h.DirHash;
        SetLength(fFoldersTES4, folderidx + 1);
        fFoldersTES4[folderidx].Hash := h.DirHash;
        fFoldersTES4[folderidx].Name := LowerCase(fdir);
        // calc folder names length
        Inc(fHeaderTES4.FolderNamesLength, Length(fdir) + 1);
        // + terminator only, length prefix is not counted
      end;
      SetLength(fFoldersTES4[folderidx].Files, fileidx + 1);
      fFoldersTES4[folderidx].Files[fileidx].Hash := h.FileHash;
      fFoldersTES4[folderidx].Files[fileidx].Name := LowerCase(fname);
      Inc(fileidx);
      Inc(fFoldersTES4[folderidx].FileCount);
      Inc(fHeaderTES4.FileCount);
      // calculate file names length
      Inc(fHeaderTES4.FileNamesLength, Length(fname) + 1); // + terminator
    end;
    fHeaderTES4.FolderCount := Length(fFoldersTES4);

    // calculate folders offsets
    // at the end fDataOffset will hold the total size of header, folder and file records
    // in other words the start of files data
    fDataOffset := SizeOf(fMagic) + SizeOf(fVersion) + SizeOf(fHeaderTES4) + 16
      * Length(fFoldersTES4);
    // SSE folder record is 8 bytes larger
    if fType = baSSE then
      Inc(fDataOffset, 8 * Length(fFoldersTES4));
    // Offsets are stored including this value
    Inc(fDataOffset, fHeaderTES4.FileNamesLength);
    for i := Low(fFoldersTES4) to High(fFoldersTES4) do
    begin
      fFoldersTES4[i].Offset := fDataOffset;
      // add folder name length
      Inc(fDataOffset, Length(fFoldersTES4[i].Name) + 2);
      // + length prefix + terminator
      // add file records length
      Inc(fDataOffset, 16 * Length(fFoldersTES4[i].Files));
    end;

    // final flags detection

    // misc file flag is not in Skyrim
    if fType = baSSE then
      fHeaderTES4.FileFlags := fHeaderTES4.FileFlags and not FILE_MISC;

    // embedded names in texture only archives
    if (fHeaderTES4.FileFlags = FILE_DDS) and ((fType <> baSSE) or fCompress) then
        fHeaderTES4.Flags := fHeaderTES4.Flags or ARCHIVE_EMBEDNAME;

    // startupstr flag in archives with meshes
    if fHeaderTES4.FileFlags and FILE_NIF <> 0 then
      fHeaderTES4.Flags := fHeaderTES4.Flags or ARCHIVE_STARTUPSTR;

    // retainname flag in archives with sounds
    if fHeaderTES4.FileFlags and FILE_WAV <> 0 then
      fHeaderTES4.Flags := fHeaderTES4.Flags or ARCHIVE_RETAINNAME;

    // txt, xml and fnt file flags are exclusive for Oblivion
    if fType = baTES4 then
      fHeaderTES4.FileFlags := fHeaderTES4.FileFlags and
        not(FILE_XML or FILE_TXT or FILE_FNT);

    // set compression flag if needed
    if fCompress then
      fHeaderTES4.Flags := fHeaderTES4.Flags or ARCHIVE_COMPRESS;
  end

  else if fType in [baFO4, baFO4dds] then
  begin
    if not Assigned(aFilesList) or (aFilesList.Count = 0) then
      raise Exception.Create('Archive requires predefined files list');

    SetLength(fFilesFO4, aFilesList.Count);
    fDataOffset := SizeOf(fMagic) + SizeOf(fVersion) + SizeOf(fHeaderFO4);

    // file records have fixed length in general archive
    if fType = baFO4 then
      fDataOffset := fDataOffset + 36 * Length(fFilesFO4)

      // variable file record length depending on DDS chunks number
    else if fType = baFO4dds then
    begin
      if not Assigned(fDDSInfoProc) then
        raise Exception.Create
          ('DDS archive requires DDS file information callback');

      for i := 0 to Pred(aFilesList.Count) do
      begin
        fDDSInfoProc(Self, PChar(aFilesList[i]), ddsinfo,
          Self.fDDSInfoProcContext);
        fDataOffset := fDataOffset + 24 { size of file record } +
          24 { size of each texchunk } * GetDDSMipChunkNum(ddsinfo);
      end;
    end;

  end;

  fStream := TwbWriteCachedFileStream.Create(aFilePath, fmCreate);
  fFileName := aFilePath;
  Include(fStates, stWriting);

  // reserve space for the header
  SetLength(Buffer, fDataOffset);
  fStream.Write(Buffer[0], Length(Buffer));
end;

procedure TwbBSArchive.Save;
var
  i, j: Integer;
begin
  if not(stWriting in fStates) then
    raise Exception.Create('Archive is not in writing mode1');

  case fType of
    baTES3:
      begin
        for i := Low(fFilesTES3) to High(fFilesTES3) do
          if fFilesTES3[i].Offset = 0 then
            raise Exception.Create('Archived file has no data: ' +
              fFilesTES3[i].Name);

        // write header
        fStream.Position := 0;
        // magic, header record
        fStream.Write(fMagic, SizeOf(fMagic));
        fStream.Write(fHeaderTES3, SizeOf(fHeaderTES3));
        // file sizes/offsets
        for i := Low(fFilesTES3) to High(fFilesTES3) do
        begin
          fStream.WriteCardinal(fFilesTES3[i].Size);
          fStream.WriteCardinal(fFilesTES3[i].Offset - fDataOffset);
          // offsets are relative
        end;
        // Archive directory/name offsets
        j := 0;
        for i := Low(fFilesTES3) to High(fFilesTES3) do
        begin
          fStream.WriteCardinal(j);
          Inc(j, Length(fFilesTES3[i].Name) + 1); // including terminator
        end;
        // Filename records
        for i := Low(fFilesTES3) to High(fFilesTES3) do
          fStream.WriteStringTerm(fFilesTES3[i].Name);
        // Hash table
        for i := Low(fFilesTES3) to High(fFilesTES3) do
        begin
          fStream.WriteCardinal(fFilesTES3[i].Hash shr 32);
          fStream.WriteCardinal(fFilesTES3[i].Hash and $FFFFFFFF);
        end;
      end;

    baTES4, baFO3, baSSE:
      begin
        // check that all files from files table have saved data
        for i := Low(fFoldersTES4) to High(fFoldersTES4) do
          for j := Low(fFoldersTES4[i].Files) to High(fFoldersTES4[i].Files) do
            if fFoldersTES4[i].Files[j].Offset = 0 then
              raise Exception.Create('Archived file has no data: ' +
                fFoldersTES4[i].Name + '\' + fFoldersTES4[i].Files[j].Name);

        // write header
        fStream.Position := 0;
        // magic, version, header record
        fStream.Write(fMagic, SizeOf(fMagic));
        fStream.Write(fVersion, SizeOf(fVersion));
        fStream.Write(fHeaderTES4, SizeOf(fHeaderTES4));
        // folder records
        for i := Low(fFoldersTES4) to High(fFoldersTES4) do
        begin
          fStream.WriteUInt64(fFoldersTES4[i].Hash);
          fStream.WriteCardinal(fFoldersTES4[i].FileCount);
          if fType = baSSE then
          begin
            fStream.WriteCardinal(fFoldersTES4[i].Unk32);
            fStream.WriteInt64(fFoldersTES4[i].Offset);
          end
          else
            fStream.WriteCardinal(fFoldersTES4[i].Offset);
        end;
        // file records
        for i := Low(fFoldersTES4) to High(fFoldersTES4) do
        begin
          fStream.WriteStringLen(fFoldersTES4[i].Name);
          for j := Low(fFoldersTES4[i].Files) to High(fFoldersTES4[i].Files) do
          begin
            fStream.WriteUInt64(fFoldersTES4[i].Files[j].Hash);
            fStream.WriteCardinal(fFoldersTES4[i].Files[j].Size);
            fStream.WriteCardinal(fFoldersTES4[i].Files[j].Offset);
          end;
        end;
        // file names
        for i := Low(fFoldersTES4) to High(fFoldersTES4) do
          for j := Low(fFoldersTES4[i].Files) to High(fFoldersTES4[i].Files) do
            fStream.WriteStringTerm(fFoldersTES4[i].Files[j].Name);
      end;

    baFO4:
      begin
        for i := Low(fFilesFO4) to High(fFilesFO4) do
          if fFilesFO4[i].Offset = 0 then
            raise Exception.Create('Archived file has no data: ' +
              fFilesFO4[i].Name);

        // file names table
        fHeaderFO4.FileTableOffset := fStream.Position;
        for i := Low(fFilesFO4) to High(fFilesFO4) do
          fStream.WriteStringLen16(fFilesFO4[i].Name);
        // write header
        fStream.Position := 0;
        // magic, version, header record
        fStream.Write(fMagic, SizeOf(fMagic));
        fStream.Write(fVersion, SizeOf(fVersion));
        fStream.Write(fHeaderFO4, SizeOf(fHeaderFO4));
        // file records
        for i := Low(fFilesFO4) to High(fFilesFO4) do
        begin
          fStream.WriteCardinal(fFilesFO4[i].NameHash);
          fStream.WriteBuffer(fFilesFO4[i].Ext[0], SizeOf(fFilesFO4[i].Ext));
          fStream.WriteCardinal(fFilesFO4[i].DirHash);
          fStream.WriteCardinal(fFilesFO4[i].Unknown);
          fStream.WriteInt64(fFilesFO4[i].Offset);
          fStream.WriteCardinal(fFilesFO4[i].PackedSize);
          fStream.WriteCardinal(fFilesFO4[i].Size);
          fStream.WriteCardinal(iFileFO4Tail);
        end;
      end;

    baFO4dds:
      begin
        for i := Low(fFilesFO4) to High(fFilesFO4) do
          if Length(fFilesFO4[i].TexChunks) = 0 then
            raise Exception.Create('Archived file has no data: ' +
              fFilesFO4[i].Name);

        // file names table
        fHeaderFO4.FileTableOffset := fStream.Position;
        for i := Low(fFilesFO4) to High(fFilesFO4) do
          fStream.WriteStringLen16(fFilesFO4[i].Name);
        // write header
        fStream.Position := 0;
        // magic, version, header record
        fStream.Write(fMagic, SizeOf(fMagic));
        fStream.Write(fVersion, SizeOf(fVersion));
        fStream.Write(fHeaderFO4, SizeOf(fHeaderFO4));
        // file records
        for i := Low(fFilesFO4) to High(fFilesFO4) do
        begin
          fStream.WriteCardinal(fFilesFO4[i].NameHash);
          fStream.WriteBuffer(fFilesFO4[i].Ext[0], SizeOf(fFilesFO4[i].Ext));
          fStream.WriteCardinal(fFilesFO4[i].DirHash);
          fStream.WriteByte(fFilesFO4[i].UnknownTex);
          fStream.WriteByte(Length(fFilesFO4[i].TexChunks));
          fStream.WriteWord(24); // fixed chunk header size
          fStream.WriteWord(fFilesFO4[i].Height);
          fStream.WriteWord(fFilesFO4[i].Width);
          fStream.WriteByte(fFilesFO4[i].NumMips);
          fStream.WriteByte(fFilesFO4[i].dxgiFormat);
          fStream.WriteWord(fFilesFO4[i].CubeMaps);
          for j := Low(fFilesFO4[i].TexChunks)
            to High(fFilesFO4[i].TexChunks) do
            with fFilesFO4[i].TexChunks[j] do
            begin
              fStream.WriteUInt64(Offset);
              fStream.WriteCardinal(PackedSize);
              fStream.WriteCardinal(Size);
              fStream.WriteWord(StartMip);
              fStream.WriteWord(EndMip);
              fStream.WriteCardinal(iFileFO4Tail);
            end;
        end;
      end

  end;

  FreeAndNil(fStream);
  Exclude(fStates, stWriting);
  Close;
end;

procedure TwbBSArchive.AddFileDisk(const aFilePath, aSourcePath: string);
var
  Buffer: PByte;
  stream: TFileStream;
begin
  if not(stWriting in fStates) then
    raise Exception.Create('Archive is not in writing mode2');

  stream := TFileStream.Create(aSourcePath, fmOpenRead + fmShareDenyNone);
  try
    // Modified: Make sure memory is zeroed when allocated
    Buffer := AllocMem(stream.Size);
    try
      stream.Read(Buffer^, stream.Size);
      AddFileDataCompat(aFilePath, stream.Size, Buffer);
    finally
      if Assigned(Buffer) then
        FreeMem(Buffer);
    end;
  finally
    stream.Free;
  end;
end;

procedure TwbBSArchive.AddFileDiskRoot(const aRootDir, aSourcePath: string);
var
  fname: string;
  i: Integer;
begin
  i := Length(aRootDir);
  if (i > 1) and (aRootDir[Length(aRootDir)] <> '\') then
    Inc(i);

  fname := Copy(aSourcePath, i + 1, Length(aSourcePath));

  AddFileDisk(fname, aSourcePath);
end;

// Modified: Version for use in non-Borland C/C++
procedure TwbBSArchive.AddFileDataCompat(const aFilePath: string;
  const aSize: Cardinal; const aData: PByte);
var
  i, j, off, MipSize, BitsPerPixel: Integer;
  fdir, fname, Name, Ext: string;
  msData: TPreallocatedMemoryStream;
  MemoryStream: TBytesStream;
  wasCompressed: Boolean;
  DataHash: TPackedDataHash;
  DDSHeader: PDDSHeader;
  DDSHeaderDX10: PDDSHeaderDX10;
  ddsinfo: TDDSInfo;
begin
  if not(stWriting in fStates) then
    raise Exception.Create('Archive is not in writing mode3');

  // FO4 dds mipmaps have their own partial hash calculation down below
  if fShareData and (fType <> baFO4dds) then
    DataHash := CalcDataHash(@aData[0], aSize);

  MemoryStream := nil;
  if Assigned(Sync) then
    Sync.BeginWrite;
  try
    case fType of
      baTES3:
        begin
          if not FindFileRecordTES3(aFilePath, i) then
            raise Exception.Create('File not found in files table: ' +
              aFilePath);

          if FindPackedData(aSize, DataHash, @fFilesTES3[i]) then
            Exit;

          fFilesTES3[i].Size := aSize;
          fFilesTES3[i].Offset := fStream.Position;
          fStream.Write(aData[0], aSize);
          AddPackedData(aSize, DataHash, @fFilesTES3[i]);
        end;

      baTES4, baFO3, baSSE:
        begin
          if not FindFileRecordTES4(aFilePath, i, j) then
            raise Exception.Create('File not found in files table: ' +
              aFilePath);

          if FindPackedData(aSize, DataHash, @fFoldersTES4[i].Files[j]) then
            Exit;

          if Assigned(Sync) and fCompress and (aSize >= 32) then
          begin
            Sync.EndWrite;
            try
              MemoryStream := TBytesStream.Create;
              msData := TPreallocatedMemoryStream.Create(@aData[0], aSize);
              try
                // store compressed data
                if fType = baSSE then
                  lz4CompressStream(msData, MemoryStream)
                else
                  ZCompressStream(msData, MemoryStream);
              finally
                msData.Free;
              end;
            finally
              Sync.BeginWrite;
            end;
            if FindPackedData(aSize, DataHash, @fFoldersTES4[i].Files[j]) then
              Exit;
          end;

          fFoldersTES4[i].Files[j].Offset := fStream.Position;

          if (fType in [baFO3, baSSE]) and
            (fHeaderTES4.Flags and ARCHIVE_EMBEDNAME <> 0) then
            fStream.WriteStringLen(fFoldersTES4[i].Name + '\' + fFoldersTES4[i]
              .Files[j].Name, False);

          if Assigned(MemoryStream) then
          begin
            fStream.WriteCardinal(aSize);
            fStream.Write(MemoryStream.Bytes[0], MemoryStream.Size);
            wasCompressed := True;
          end
          else if fCompress and (aSize >= 32) then
          begin
            msData := TPreallocatedMemoryStream.Create(@aData[0], aSize);
            try
              // store uncompressed length
              fStream.WriteCardinal(aSize);
              // store compressed data
              if fType = baSSE then
                lz4CompressStream(msData, fStream)
              else
                ZCompressStream(msData, fStream);
            finally
              msData.Free;
            end;
            wasCompressed := True;
          end
          else
          begin
            fStream.Write(aData[0], aSize);
            wasCompressed := False;
          end;

          fFoldersTES4[i].Files[j].Size := fStream.Position - fFoldersTES4[i]
            .Files[j].Offset;

          // compress flag in Size inverts compression status from the header
          // set it if archive is flagged as compressed but file was not compressed
          if fCompress and not wasCompressed then
            fFoldersTES4[i].Files[j].Size := fFoldersTES4[i].Files[j].Size or
              FILE_SIZE_COMPRESS;

          AddPackedData(aSize, DataHash, @fFoldersTES4[i].Files[j]);
        end;

      baFO4:
        begin
          if SplitDirName(aFilePath, fdir, fname) = 0 then
            raise Exception.Create('File is missing the folder part: ' +
              aFilePath);

          SplitNameExt(fname, name, Ext);
          if Length(Ext) > 1 then
            Delete(Ext, 1, 1); // no dot in extension

          i := fHeaderFO4.FileCount;
          Inc(fHeaderFO4.FileCount);
          // archive2.exe uses /
          fFilesFO4[i].Name := StringReplace(aFilePath, '\', '/',
            [rfReplaceAll]);
          fFilesFO4[i].DirHash := CreateHashFO4(fdir);
          fFilesFO4[i].NameHash := CreateHashFO4(name);
          fFilesFO4[i].Ext := Int2Magic(Str2MagicInt(Ext));
          fFilesFO4[i].Unknown := iFileFO4Unknown;
          fFilesFO4[i].Offset := fStream.Position;
          fFilesFO4[i].Size := aSize;

          if FindPackedData(aSize, DataHash, @fFilesFO4[i]) then
            Exit;

          if fCompress and (aSize >= 32) then
          begin
            msData := TPreallocatedMemoryStream.Create(@aData[0], aSize);
            try
              ZCompressStream(msData, fStream);
              fFilesFO4[i].PackedSize := fStream.Position - fFilesFO4[i].Offset;
              // rare case: if packed size matches original, then rewrite with original data
              if fFilesFO4[i].PackedSize = fFilesFO4[i].Size then
              begin
                fFilesFO4[i].PackedSize := 0;
                fStream.Position := fFilesFO4[i].Offset;
                fStream.Write(aData[0], aSize);
              end;
            finally
              msData.Free;
            end;
          end
          else
            fStream.Write(aData[0], aSize);

          AddPackedData(aSize, DataHash, @fFilesFO4[i]);
        end;

      baFO4dds:
        begin
          if SplitDirName(aFilePath, fdir, fname) = 0 then
            raise Exception.Create('File is missing the folder part: ' +
              aFilePath);

          SplitNameExt(fname, name, Ext);
          if Length(Ext) > 1 then
            Delete(Ext, 1, 1); // no dot in extension

          // filling common part
          i := fHeaderFO4.FileCount;
          Inc(fHeaderFO4.FileCount);
          // archive2.exe uses /
          fFilesFO4[i].Name := StringReplace(aFilePath, '\', '/',
            [rfReplaceAll]);
          fFilesFO4[i].DirHash := CreateHashFO4(fdir);
          fFilesFO4[i].NameHash := CreateHashFO4(name);
          fFilesFO4[i].Ext := Int2Magic(Str2MagicInt(Ext));
          fFilesFO4[i].UnknownTex := 0;

          // DDS file parameters
          DDSHeader := @aData[0];
          off := SizeOf(DDSHeader^); // offset to image data
          fFilesFO4[i].Width := DDSHeader.dwWidth;
          fFilesFO4[i].Height := DDSHeader.dwHeight;
          fFilesFO4[i].NumMips := DDSHeader.dwMipMapCount;
          // no mipmaps is equal to a single one
          if fFilesFO4[i].NumMips = 0 then
            fFilesFO4[i].NumMips := 1;

          // DXGI detection
          if DDSHeader.ddspf.dwFourCC = MAGIC_DXT1 then
            fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_BC1_UNORM)
          else if DDSHeader.ddspf.dwFourCC = MAGIC_DXT3 then
            fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_BC2_UNORM)
          else if DDSHeader.ddspf.dwFourCC = MAGIC_DXT5 then
            fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_BC3_UNORM)
          else if DDSHeader.ddspf.dwFourCC = MAGIC_ATI1 then
            fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_BC4_UNORM)
          else if DDSHeader.ddspf.dwFourCC = MAGIC_BC4U then
            fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_BC4_UNORM)
          else if DDSHeader.ddspf.dwFourCC = MAGIC_BC4S then
            fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_BC4_SNORM)
          else if DDSHeader.ddspf.dwFourCC = MAGIC_ATI2 then
            fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_BC5_UNORM)
          else if DDSHeader.ddspf.dwFourCC = MAGIC_BC5U then
            fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_BC5_UNORM)
          else if DDSHeader.ddspf.dwFourCC = MAGIC_BC5S then
            fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_BC5_SNORM)
          else if DDSHeader.ddspf.dwFourCC = MAGIC_DX10 then
          begin
            DDSHeaderDX10 := @aData[off];
            off := off + SizeOf(DDSHeaderDX10^);
            fFilesFO4[i].dxgiFormat := Byte(DDSHeaderDX10.dxgiFormat);
          end
          else
          begin
            if DDSHeader.ddspf.dwRGBBitCount = 32 then
              if DDSHeader.ddspf.dwFlags and DDPF_ALPHAPIXELS = 0 then
                fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_B8G8R8X8_UNORM)
              else if DDSHeader.ddspf.dwRBitMask = $000000FF then
                fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_R8G8B8A8_UNORM)
              else
                fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_B8G8R8A8_UNORM)
            else if DDSHeader.ddspf.dwRGBBitCount = 16 then
              if (DDSHeader.ddspf.dwRBitMask = $F800) and
                (DDSHeader.ddspf.dwGBitMask = $07E0) and
                (DDSHeader.ddspf.dwBBitMask = $001F) and
                (DDSHeader.ddspf.dwABitMask = $0000) then
                fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_B5G6R5_UNORM)
              else if (DDSHeader.ddspf.dwRBitMask = $7C00) and
                (DDSHeader.ddspf.dwGBitMask = $03E0) and
                (DDSHeader.ddspf.dwBBitMask = $001F) and
                (DDSHeader.ddspf.dwABitMask = $8000) then
                fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_B5G5R5A1_UNORM)
              else
                fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_R8G8_UNORM)
            else if DDSHeader.ddspf.dwRGBBitCount = 8 then
              if DDSHeader.ddspf.dwFlags and DDPF_ALPHA <> 0 then
                fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_A8_UNORM)
              else
                fFilesFO4[i].dxgiFormat := Byte(DXGI_FORMAT_R8_UNORM)
            else
              raise Exception.Create('Unsupported uncompressed DDS format');
          end;

          // MipMap size detection
          case TDXGI(fFilesFO4[i].dxgiFormat) of
            DXGI_FORMAT_BC1_UNORM, DXGI_FORMAT_BC1_UNORM_SRGB,
              DXGI_FORMAT_BC4_UNORM, DXGI_FORMAT_BC4_SNORM:
              BitsPerPixel := 4;
            DXGI_FORMAT_BC2_UNORM, DXGI_FORMAT_BC2_UNORM_SRGB,
              DXGI_FORMAT_BC3_UNORM, DXGI_FORMAT_BC3_UNORM_SRGB,
              DXGI_FORMAT_BC5_UNORM, DXGI_FORMAT_BC5_SNORM,
              DXGI_FORMAT_BC6H_SF16, DXGI_FORMAT_BC6H_UF16,
              DXGI_FORMAT_BC7_UNORM, DXGI_FORMAT_BC7_UNORM_SRGB,
              DXGI_FORMAT_A8_UNORM, DXGI_FORMAT_R8_SINT, DXGI_FORMAT_R8_SNORM,
              DXGI_FORMAT_R8_UINT, DXGI_FORMAT_R8_UNORM:
              BitsPerPixel := 8;
            DXGI_FORMAT_B5G6R5_UNORM, DXGI_FORMAT_B5G5R5A1_UNORM,
              DXGI_FORMAT_R8G8_SINT, DXGI_FORMAT_R8G8_UINT,
              DXGI_FORMAT_R8G8_UNORM:
              BitsPerPixel := 16;
            DXGI_FORMAT_B8G8R8A8_UNORM, DXGI_FORMAT_B8G8R8A8_UNORM_SRGB,
              DXGI_FORMAT_B8G8R8X8_UNORM, DXGI_FORMAT_B8G8R8X8_UNORM_SRGB,
              DXGI_FORMAT_R8G8B8A8_UNORM, DXGI_FORMAT_R8G8B8A8_SINT,
              DXGI_FORMAT_R8G8B8A8_UINT, DXGI_FORMAT_R8G8B8A8_UNORM_SRGB:
              BitsPerPixel := 32;
          else
            raise Exception.Create('Unsupported DDS format');
          end;
          MipSize := (fFilesFO4[i].Width * fFilesFO4[i].Height *
            BitsPerPixel) shr 3;

          // cubemaps detection
          fFilesFO4[i].CubeMaps := $800;
          if DDSHeader.dwCaps2 and DDSCAPS2_CUBEMAP <> 0 then
            fFilesFO4[i].CubeMaps := fFilesFO4[i].CubeMaps or 1;

          // number of chunks to store in file record
          ddsinfo.Width := fFilesFO4[i].Width;
          ddsinfo.Height := fFilesFO4[i].Height;
          ddsinfo.MipMaps := fFilesFO4[i].NumMips;
          SetLength(fFilesFO4[i].TexChunks, GetDDSMipChunkNum(ddsinfo));

          // storing chunks
          for j := Low(fFilesFO4[i].TexChunks)
            to High(fFilesFO4[i].TexChunks) do
          begin
            fFilesFO4[i].TexChunks[j].StartMip := j;
            if j < High(fFilesFO4[i].TexChunks) then
              fFilesFO4[i].TexChunks[j].EndMip := j
            else
            begin
              // last chunk stores all remaining mipmaps
              fFilesFO4[i].TexChunks[j].EndMip := Pred(fFilesFO4[i].NumMips);
              MipSize := Integer(aSize) - off;
            end;

            DataHash := CalcDataHash(@aData[off], MipSize);
            if not FindPackedData(MipSize, DataHash, @fFilesFO4[i].TexChunks[j])
            then
            begin
              fFilesFO4[i].TexChunks[j].Offset := fStream.Position;
              fFilesFO4[i].TexChunks[j].Size := MipSize;
              if fCompress then
              begin
                msData := TPreallocatedMemoryStream.Create(@aData[off],
                  MipSize);
                try
                  ZCompressStream(msData, fStream);
                  fFilesFO4[i].TexChunks[j].PackedSize := fStream.Position -
                    fFilesFO4[i].TexChunks[j].Offset;
                finally
                  msData.Free;
                end;
              end
              else
                fStream.Write(aData[off], MipSize);

              AddPackedData(MipSize, DataHash, @fFilesFO4[i].TexChunks[j]);
            end;
            Inc(off, MipSize);
            MipSize := MipSize div 4;
          end;
        end;

    end;
  finally
    if Assigned(Sync) then
      Sync.EndWrite;
    FreeAndNil(MemoryStream);
  end;
end;

// Modified: Version for use in non-Borland C/C++ (Result not automatically freed)
function TwbBSArchive.ExtractFileDataCompat(aFileRecord: Pointer)
  : TwbBSResultBuffer;
var
  FileTES3: PwbBSFileTES3;
  FileTES4: PwbBSFileTES4;
  FileFO4: PwbBSFileFO4;
  DDSHeader: PDDSHeader;
  DDSHeaderDX10: PDDSHeaderDX10;
  i, Size, TexSize: Integer;
  bCompressed: Boolean;
  Buffer: TBytes;
begin
  if not(stReading in fStates) then
    raise Exception.Create('Archive is not loaded');

  if aFileRecord = nil then
    Exit;

  if Assigned(Sync) then
    Sync.BeginWrite;
  try
    case fType of
      baTES3:
        begin
          FileTES3 := aFileRecord;
          fStream.Position := fDataOffset + FileTES3.Offset;
          Result.Size := FileTES3.Size;
          // Modified: Make sure memory is zeroed when allocated
          Result.data := AllocMem(FileTES3.Size);
        end;

      baTES4, baFO3, baSSE:
        begin
          FileTES4 := aFileRecord;
          fStream.Position := FileTES4.Offset;
          Size := FileTES4.Size;

          bCompressed := Size and FILE_SIZE_COMPRESS <> 0;
          if bCompressed then
            Size := Size and not FILE_SIZE_COMPRESS;
          if fHeaderTES4.Flags and ARCHIVE_COMPRESS <> 0 then
            bCompressed := not bCompressed;

          // skip embedded file name + length prefix
          if (fType in [baFO3, baSSE]) and
            (fHeaderTES4.Flags and ARCHIVE_EMBEDNAME <> 0) then
            Size := Size - (Length(fStream.ReadStringLen(False)) + 1);

          if bCompressed then
          begin
            // reading uncompressed size
            Result.Size := fStream.ReadCardinal;
            // Modified: Make sure memory is zeroed when allocated
            Result.data := AllocMem(Result.Size);
            dec(Size, SizeOf(Cardinal));
            if (Result.Size > 0) and (Size > 0) then
            begin
              SetLength(Buffer, Size);
              fStream.ReadBuffer(Buffer[0], Length(Buffer));
              if Assigned(Sync) then
                Sync.EndWrite;
              try
                if fType = baSSE then
                  lz4DecompressToUserBuf(@Buffer[0], Length(Buffer),
                    @Result.data[0], Result.Size)
                else
                  try
                    DecompressToUserBuf(@Buffer[0], Length(Buffer),
                      @Result.data[0], Result.Size);
                  except
                    // ignore zlib's Buffer error since it happens in vanilla "Fallout - Misc.bsa"
                    // Bethesda probably used old buggy zlib version when packing it
                    on e: Exception do
                      if e.Message <> 'Buffer error' then
                        raise;
                  end;
              finally
                if Assigned(Sync) then
                  Sync.BeginWrite;
              end;
            end;
          end
          else
          begin
            Result.Size := Size;
            // Modified: Make sure memory is zeroed when allocated
            Result.data := AllocMem(Result.Size);
            if Size > 0 then
              fStream.ReadBuffer(Result.data[0], Result.Size);
          end;
        end;

      baFO4:
        begin
          FileFO4 := aFileRecord;
          fStream.Position := FileFO4.Offset;
          if FileFO4.PackedSize <> 0 then
          begin
            SetLength(Buffer, FileFO4.PackedSize);
            fStream.ReadBuffer(Buffer[0], Length(Buffer));
            Result.Size := FileFO4.Size;
            // Modified: Make sure memory is zeroed when allocated
            Result.data := AllocMem(Result.Size);
            if Assigned(Sync) then
              Sync.EndWrite;
            try
              DecompressToUserBuf(@Buffer[0], Length(Buffer), @Result.data[0],
                Result.Size);
            finally
              if Assigned(Sync) then
                Sync.BeginWrite;
            end;
          end
          else
          begin
            Result.Size := FileFO4.Size;
            // Modified: Make sure memory is zeroed when allocated
            Result.data := AllocMem(Result.Size);
            fStream.ReadBuffer(Result.data[0], Result.Size);
          end;
        end;

      baFO4dds:
        begin
          FileFO4 := aFileRecord;

          TexSize := SizeOf(TDDSHeader);

          for i := Low(FileFO4.TexChunks) to High(FileFO4.TexChunks) do
            Inc(TexSize, FileFO4.TexChunks[i].Size);

          Result.Size := TexSize;

          // Modified: Make sure memory is zeroed when allocated
          Result.data := AllocMem(Result.Size);

          DDSHeader := @Result.data[0];
          DDSHeader.Magic := MAGIC_DDS;
          DDSHeader.dwSize := SizeOf(TDDSHeader) - SizeOf(TMagic4);
          DDSHeader.dwWidth := FileFO4.Width;
          DDSHeader.dwHeight := FileFO4.Height;
          DDSHeader.dwFlags := DDSD_CAPS or DDSD_PIXELFORMAT or DDSD_WIDTH or
            DDSD_HEIGHT or DDSD_MIPMAPCOUNT;
          DDSHeader.dwCaps := DDSCAPS_TEXTURE;
          DDSHeader.dwMipMapCount := FileFO4.NumMips;
          if DDSHeader.dwMipMapCount > 1 then
            DDSHeader.dwCaps := DDSHeader.dwCaps or DDSCAPS_MIPMAP or
              DDSCAPS_COMPLEX;
          DDSHeader.dwDepth := 1;

          DDSHeaderDX10 := @Result.data[SizeOf(TDDSHeader)];
          DDSHeaderDX10.resourceDimension := DDS_DIMENSION_TEXTURE2D;
          DDSHeaderDX10.arraySize := 1;

          if FileFO4.CubeMaps = 2049 then
          begin
            DDSHeader.dwCaps := DDSHeader.dwCaps or DDSCAPS2_CUBEMAP or
              DDSCAPS_COMPLEX or DDSCAPS2_POSITIVEX or DDSCAPS2_NEGATIVEX or
              DDSCAPS2_POSITIVEY or DDSCAPS2_NEGATIVEY or DDSCAPS2_POSITIVEZ or
              DDSCAPS2_NEGATIVEZ;
            DDSHeaderDX10.miscFlags := DDS_RESOURCE_MISC_TEXTURECUBE;
          end;
          DDSHeader.ddspf.dwSize := SizeOf(DDSHeader.ddspf);
          case TDXGI(FileFO4.dxgiFormat) of
            DXGI_FORMAT_BC1_UNORM:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_LINEARSIZE;
                DDSHeader.ddspf.dwFlags := DDPF_FOURCC;
                DDSHeader.ddspf.dwFourCC := MAGIC_DXT1;
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width *
                  FileFO4.Height div 2;
              end;
            DXGI_FORMAT_BC2_UNORM:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_LINEARSIZE;
                DDSHeader.ddspf.dwFlags := DDPF_FOURCC;
                DDSHeader.ddspf.dwFourCC := MAGIC_DXT3;
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width * FileFO4.Height;
              end;
            DXGI_FORMAT_BC3_UNORM:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_LINEARSIZE;
                DDSHeader.ddspf.dwFlags := DDPF_FOURCC;
                DDSHeader.ddspf.dwFourCC := MAGIC_DXT5;
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width * FileFO4.Height;
              end;
            DXGI_FORMAT_BC4_SNORM:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_LINEARSIZE;
                DDSHeader.ddspf.dwFlags := DDPF_FOURCC;
                DDSHeader.ddspf.dwFourCC := MAGIC_BC4S;
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width *
                  FileFO4.Height div 2;
              end;
            DXGI_FORMAT_BC4_UNORM:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_LINEARSIZE;
                DDSHeader.ddspf.dwFlags := DDPF_FOURCC;
                DDSHeader.ddspf.dwFourCC := MAGIC_BC4U;
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width *
                  FileFO4.Height div 2;
              end;
            DXGI_FORMAT_BC5_SNORM:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_LINEARSIZE;
                DDSHeader.ddspf.dwFlags := DDPF_FOURCC;
                DDSHeader.ddspf.dwFourCC := MAGIC_BC5S;
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width * FileFO4.Height;
              end;
            DXGI_FORMAT_BC5_UNORM:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_LINEARSIZE;
                DDSHeader.ddspf.dwFlags := DDPF_FOURCC;
                DDSHeader.ddspf.dwFourCC := MAGIC_BC5U;
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width * FileFO4.Height;
              end;
            DXGI_FORMAT_BC1_UNORM_SRGB:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_LINEARSIZE;
                DDSHeader.ddspf.dwFlags := DDPF_FOURCC;
                DDSHeader.ddspf.dwFourCC := MAGIC_DX10;
                DDSHeaderDX10.dxgiFormat := Integer(FileFO4.dxgiFormat);
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width *
                  FileFO4.Height div 2;
              end;
            DXGI_FORMAT_BC2_UNORM_SRGB, DXGI_FORMAT_BC3_UNORM_SRGB,
              DXGI_FORMAT_BC6H_UF16, DXGI_FORMAT_BC6H_SF16,
              DXGI_FORMAT_BC7_UNORM, DXGI_FORMAT_BC7_UNORM_SRGB:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_LINEARSIZE;
                DDSHeader.ddspf.dwFlags := DDPF_FOURCC;
                DDSHeader.ddspf.dwFourCC := MAGIC_DX10;
                DDSHeaderDX10.dxgiFormat := Integer(FileFO4.dxgiFormat);
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width * FileFO4.Height;
              end;
            DXGI_FORMAT_B8G8R8A8_UNORM_SRGB, DXGI_FORMAT_B8G8R8X8_UNORM_SRGB,
              DXGI_FORMAT_R8G8B8A8_SINT, DXGI_FORMAT_R8G8B8A8_UINT,
              DXGI_FORMAT_R8G8B8A8_UNORM_SRGB:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_PITCH;
                DDSHeader.ddspf.dwFlags := DDPF_FOURCC;
                DDSHeader.ddspf.dwFourCC := MAGIC_DX10;
                DDSHeaderDX10.dxgiFormat := Integer(FileFO4.dxgiFormat);
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width * 4;
              end;
            DXGI_FORMAT_R8G8_SINT, DXGI_FORMAT_R8G8_UINT:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_PITCH;
                DDSHeader.ddspf.dwFlags := DDPF_FOURCC;
                DDSHeader.ddspf.dwFourCC := MAGIC_DX10;
                DDSHeaderDX10.dxgiFormat := Integer(FileFO4.dxgiFormat);
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width * 2;
              end;
            DXGI_FORMAT_R8_SINT, DXGI_FORMAT_R8_SNORM, DXGI_FORMAT_R8_UINT:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_PITCH;
                DDSHeader.ddspf.dwFlags := DDPF_FOURCC;
                DDSHeader.ddspf.dwFourCC := MAGIC_DX10;
                DDSHeaderDX10.dxgiFormat := Integer(FileFO4.dxgiFormat);
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width;
              end;
            DXGI_FORMAT_R8G8B8A8_UNORM:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_PITCH;
                DDSHeader.ddspf.dwFlags := DDPF_RGB or DDPF_ALPHAPIXELS;
                DDSHeader.ddspf.dwRGBBitCount := 32;
                DDSHeader.ddspf.dwRBitMask := $000000FF;
                DDSHeader.ddspf.dwGBitMask := $0000FF00;
                DDSHeader.ddspf.dwBBitMask := $00FF0000;
                DDSHeader.ddspf.dwABitMask := $FF000000;
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width * 4;
              end;
            DXGI_FORMAT_B8G8R8A8_UNORM:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_PITCH;
                DDSHeader.ddspf.dwFlags := DDPF_RGB or DDPF_ALPHAPIXELS;
                DDSHeader.ddspf.dwRGBBitCount := 32;
                DDSHeader.ddspf.dwRBitMask := $00FF0000;
                DDSHeader.ddspf.dwGBitMask := $0000FF00;
                DDSHeader.ddspf.dwBBitMask := $000000FF;
                DDSHeader.ddspf.dwABitMask := $FF000000;
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width * 4;
              end;
            DXGI_FORMAT_B8G8R8X8_UNORM:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_PITCH;
                DDSHeader.ddspf.dwFlags := DDPF_RGB;
                DDSHeader.ddspf.dwRGBBitCount := 32;
                DDSHeader.ddspf.dwRBitMask := $00FF0000;
                DDSHeader.ddspf.dwGBitMask := $0000FF00;
                DDSHeader.ddspf.dwBBitMask := $000000FF;
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width * 4;
              end;
            DXGI_FORMAT_B5G6R5_UNORM:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_PITCH;
                DDSHeader.ddspf.dwFlags := DDPF_RGB;
                DDSHeader.ddspf.dwRGBBitCount := 16;
                DDSHeader.ddspf.dwRBitMask := $0000F800;
                DDSHeader.ddspf.dwGBitMask := $000007E0;
                DDSHeader.ddspf.dwBBitMask := $0000001F;
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width * 2;
              end;
            DXGI_FORMAT_B5G5R5A1_UNORM:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_PITCH;
                DDSHeader.ddspf.dwFlags := DDPF_RGB or DDPF_ALPHAPIXELS;
                DDSHeader.ddspf.dwRGBBitCount := 16;
                DDSHeader.ddspf.dwRBitMask := $00007C00;
                DDSHeader.ddspf.dwGBitMask := $000003E0;
                DDSHeader.ddspf.dwBBitMask := $0000001F;
                DDSHeader.ddspf.dwABitMask := $00008000;
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width * 2;
              end;
            DXGI_FORMAT_R8G8_UNORM:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_PITCH;
                DDSHeader.ddspf.dwFlags := DDPF_LUMINANCE OR DDPF_ALPHAPIXELS;
                DDSHeader.ddspf.dwRGBBitCount := 16;
                DDSHeader.ddspf.dwRBitMask := $000000FF;
                DDSHeader.ddspf.dwABitMask := $0000FF00;
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width * 2;
              end;
            DXGI_FORMAT_A8_UNORM:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_PITCH;
                DDSHeader.ddspf.dwFlags := DDPF_ALPHA;
                DDSHeader.ddspf.dwRGBBitCount := 8;
                DDSHeader.ddspf.dwABitMask := $000000FF;
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width;
              end;
            DXGI_FORMAT_R8_UNORM:
              begin
                DDSHeader.dwFlags := DDSHeader.dwFlags or DDSD_PITCH;
                DDSHeader.ddspf.dwFlags := DDPF_LUMINANCE;
                DDSHeader.ddspf.dwRGBBitCount := 8;
                DDSHeader.ddspf.dwRBitMask := $000000FF;
                DDSHeader.dwPitchOrLinearSize := FileFO4.Width;
              end;
          end;
          TexSize := SizeOf(TDDSHeader);
          if DDSHeader.ddspf.dwFourCC = MAGIC_DX10 then
          begin
            ReallocMem(Result.data, Result.Size + SizeOf(TDDSHeaderDX10));
            Inc(TexSize, SizeOf(TDDSHeaderDX10));
            Result.Size := TexSize;
          end;
          // append chunks
          for i := Low(FileFO4.TexChunks) to High(FileFO4.TexChunks) do
            with FileFO4.TexChunks[i] do
            begin
              fStream.Position := Offset;
              // compressed chunk
              if PackedSize <> 0 then
              begin
                SetLength(Buffer, PackedSize);
                fStream.ReadBuffer(Buffer[0], Length(Buffer));
                if Assigned(Sync) then
                  Sync.EndWrite;
                try
                  DecompressToUserBuf(@Buffer[0], Length(Buffer),
                    @Result.data[TexSize], Size);
                finally
                  if Assigned(Sync) then
                    Sync.BeginWrite;
                end;
              end
              // uncompressed chunk
              else
                fStream.ReadBuffer(Result.data[TexSize], Size);
              Inc(TexSize, Size);
              Result.Size := TexSize;
            end;
        end

    else
      raise Exception.Create('Extraction is not supported for this archive');
    end;
  finally
    if Assigned(Sync) then
      Sync.EndWrite;
  end;
end;

// Modified: Version for use in non-Borland C/C++
function TwbBSArchive.ExtractFileDataCompat(const aFilePath: string)
  : TwbBSResultBuffer;
var
  FileRecord: Pointer;
begin
  if not(stReading in fStates) then
    raise Exception.Create('Archive is not loaded');

  FileRecord := FindFileRecord(aFilePath);

  if not Assigned(FileRecord) then
    raise Exception.Create('File not found in archive');

  Result := ExtractFileDataCompat(FileRecord);
end;

// Addded: For use in non-Borland C/C++
procedure TwbBSArchive.ReleaseFileDataCompat(fileDataResult: TwbBSResultBuffer);
begin
  FreeMem(fileDataResult.data);
  fileDataResult.Size := 0;
end;

procedure TwbBSArchive.ExtractFile(const aFilePath, aSaveAs: string);
var
  fs: TFileStream;
  fileData: TwbBSResultBuffer;
begin
  if not(stReading in fStates) then
    raise Exception.Create('Archive is not loaded');

  fs := TFileStream.Create(aSaveAs, fmCreate);
  try
    fileData := ExtractFileDataCompat(aFilePath);
    fs.Write(fileData.data[0], fileData.Size);
  finally
    ReleaseFileDataCompat(fileData);
    fs.Free;
  end;
end;

type
  TIterUnpackContext = record
    Dir: PChar;
    overwriteCurrentFiles: Boolean;
  end;

  PIterUnpackContext = ^TIterUnpackContext;

function IterUnpackFile(aArchive: Pointer; const aFilePath: PChar;
  aFileRecord: Pointer; aFolderRecord: Pointer; aContext: Pointer)
  : Boolean; stdcall;
var
  bsa: TwbBSArchive;
  Dir, fname: string;
  fileData: TwbBSResultBuffer;
  context: PIterUnpackContext;
begin
  Result := False;

  context := PIterUnpackContext(aContext);

  bsa := TwbBSArchive(aArchive);
  // fo4 archives can contain backslashes
  fname := StringReplace(aFilePath, '/', '\', [rfReplaceAll]);

  Dir := context.Dir;

  if not DirectoryExists(Dir + ExtractFilePath(fname)) then
  begin
    if Assigned(bsa.Sync) then
      bsa.Sync.BeginWrite;
    try
      if not ForceDirectories(Dir + ExtractFilePath(fname)) then
        if not DirectoryExists(Dir + ExtractFilePath(fname)) then
          raise Exception.Create('Can not create destination folder: ' + Dir +
            ExtractFilePath(fname));

      if FileExists(Dir + fname) and not context.overwriteCurrentFiles then
        Exit;

      if FileExists(Dir + fname) then
        DeleteFile(PChar(Dir + fname));

    finally
      if Assigned(bsa.Sync) then
        bsa.Sync.EndWrite;
    end;
  end;

  try
    fileData := bsa.ExtractFileDataCompat(aFileRecord);
  except
    on e: Exception do
    begin
      bsa.ReleaseFileDataCompat(fileData);
      raise Exception.Create('Unpacking error "' + fname + '": ' + e.Message);
    end;
  end;

  with TFileStream.Create(Dir + fname, fmCreate) do
    try
      Write(fileData.data[0], fileData.Size);
    finally
      Free;
    end;

  bsa.ReleaseFileDataCompat(fileData);
end;

procedure TwbBSArchive.ExtractAllFiles(const aFolderName: string;
  aOverwriteCurrentFiles: Boolean);
var
  context: TIterUnpackContext;
begin
  if not DirectoryExists(aFolderName) then
    raise Exception.Create('Folder does not exist: ' + aFolderName);

  context.Dir := PChar(IncludeTrailingPathDelimiter(aFolderName));
  context.overwriteCurrentFiles := aOverwriteCurrentFiles;
  IterateFilesCompat(@IterUnpackFile, @context);
end;

// Modified: Version for use in non-Borland C/C++
procedure TwbBSArchive.IterateFilesCompat(aProc: TBSFileIterationProcCompat;
  aContext: Pointer = nil);
var
  i, j: Integer;
begin
  if not Assigned(aProc) then
    Exit;

  if Assigned(Sync) then
    case fType of
      baTES3:
        TParallel.&For(Low(fFilesTES3), High(fFilesTES3),
          procedure(i: Integer; LoopState: TParallel.TLoopState)
          begin
            if aProc(Self, PChar(fFilesTES3[i].Name), @fFilesTES3[i], nil,
              aContext) then
              LoopState.Stop;
          end);
      baTES4, baFO3, baSSE:
        TParallel.&For(Low(fFoldersTES4), High(fFoldersTES4),
          procedure(i: Integer; OuterLoopState: TParallel.TLoopState)
          begin
            TParallel.&For(Low(fFoldersTES4[i].Files),
              High(fFoldersTES4[i].Files),
              procedure(j: Integer; InnerLoopState: TParallel.TLoopState)
              begin
                if aProc(Self, PChar(fFoldersTES4[i].Name + '\' + fFoldersTES4
                  [i].Files[j].Name), @fFoldersTES4[i].Files[j],
                  @fFoldersTES4[i], aContext) then
                begin
                  OuterLoopState.Stop;
                  InnerLoopState.Stop;
                end;
              end);
          end);
      baFO4, baFO4dds:
        TParallel.&For(Low(fFilesFO4), High(fFilesFO4),
          procedure(i: Integer; LoopState: TParallel.TLoopState)
          begin
            if aProc(Self, PChar(fFilesFO4[i].Name), @fFilesFO4[i], nil,
              aContext) then
              LoopState.Stop;
          end);
    end
  else
    case fType of
      baTES3:
        for i := Low(fFilesTES3) to High(fFilesTES3) do
          if aProc(Self, PChar(fFilesTES3[i].Name), @fFilesTES3[i], nil,
            aContext) then
            Break;
      baTES4, baFO3, baSSE:
        for i := Low(fFoldersTES4) to High(fFoldersTES4) do
          for j := Low(fFoldersTES4[i].Files) to High(fFoldersTES4[i].Files) do
            if aProc(Self, PChar(fFoldersTES4[i].Name + '\' + fFoldersTES4[i]
              .Files[j].Name), @fFoldersTES4[i].Files[j], @fFoldersTES4[i],
              aContext) then
              Break;
      baFO4, baFO4dds:
        for i := Low(fFilesFO4) to High(fFilesFO4) do
          if aProc(Self, PChar(fFilesFO4[i].Name), @fFilesFO4[i], nil, aContext)
          then
            Break;
    end;
end;

function TwbBSArchive.FileExists(const aFilePath: string): Boolean;
begin
  Result := Assigned(FindFileRecord(aFilePath));
end;

procedure TwbBSArchive.Close;
begin
  if Assigned(fStream) then
    FreeAndNil(fStream);

  if stWriting in fStates then
    SysUtils.DeleteFile(fFileName);

  fStates := [];
  fType := baNone;
  fFileName := '';
  fDataOffset := 0;
  FillChar(fHeaderTES3, SizeOf(fHeaderTES3), 0);
  SetLength(fFilesTES3, 0);
  FillChar(fHeaderTES4, SizeOf(fHeaderTES4), 0);
  SetLength(fFoldersTES4, 0);
  FillChar(fHeaderFO4, SizeOf(fHeaderFO4), 0);
  SetLength(fFilesFO4, 0);

  if fShareData then
  begin
    SetLength(fPackedData, 0);
    fPackedDataCount := 0;
  end;
end;

procedure TwbBSArchive.ResourceListCompat(const aEntryResultList
  : TwbBSEntryList; aFolder: string = '');
var
  Folder: string;
  i, j: Integer;
begin
  if not Assigned(aEntryResultList) then
    Exit;

  Folder := ExcludeTrailingPathDelimiter(aFolder);
  case fType of
    baTES3:
      for i := Low(fFilesTES3) to High(fFilesTES3) do
        with fFilesTES3[i] do
          if (Folder = '') or Name.StartsWith(Folder, True) then
            aEntryResultList.Add(Name);
    baTES4, baFO3, baSSE:
      for i := Low(fFoldersTES4) to High(fFoldersTES4) do
        with fFoldersTES4[i] do
        begin
          if (Folder = '') or Name.StartsWith(Folder, True) then
            for j := Low(Files) to High(Files) do
              aEntryResultList.Add(Name + '\' + Files[j].Name);
        end;
    baFO4, baFO4dds:
      for i := Low(fFilesFO4) to High(fFilesFO4) do
        with fFilesFO4[i] do
          if (Folder = '') or Name.StartsWith(Folder, True) then
            aEntryResultList.Add(Name);
  end;

end;

procedure TwbBSArchive.ResolveHashCompat(const aHash: UInt64;
const aEntryResultList: TwbBSEntryList);
var
  len: Integer;
  i, j: Integer;
begin
  case fType of
    baTES3:
      for i := Low(fFilesTES3) to High(fFilesTES3) do
        with fFilesTES3[i] do
          if aHash = Hash then
          begin
            aEntryResultList.Add(Name);
          end;
    baTES4, baFO3, baSSE:
      for i := Low(fFoldersTES4) to High(fFoldersTES4) do
        with fFoldersTES4[i] do
        begin
          if aHash = Hash then
          begin
            aEntryResultList.Add(Name);
          end;
          for j := Low(Files) to High(Files) do
            with Files[j] do
              if aHash = Hash then
              begin
                aEntryResultList.Add(Name);
              end;
        end;
    {
      baFO4, baFO4dds:
      for i := Low(fFilesFO4) to High(fFilesFO4) do
      with fFilesFO4[i] do begin
      if aHash = NameHash then begin
      SetLength(Results, Succ(Len));
      Results[Len] := Name;
      Inc(Len);
      end;
      end;
    }
  end;
end;

end.
