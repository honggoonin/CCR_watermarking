# Copyright(c) 2018, Hyungjoon Koo
# Copyright(c) 2021, Honggoo Kang
#####################################################################
#  SoftMark: Software Watermarking via a Binary Function Relocation #
#   (In the Annual Computer SEcurity Applications Conference 2021)  # 
#                                                                   #
#  Author: Honggoo Kang <honggoonin@korea.ac.kr>                    #
#          Cybersecurity@Korea University                           #
#                                                                   #
#  This file can be distributed under the MIT License.              #
#  See the LICENSE.TXT for details.                                 #
#####################################################################

from distutils import spawn

def enum(*seq, **named):
    enums = dict(zip(seq, range(len(seq))), **named)
    return type('Enum', (), enums)

Formats = enum('CHAR', 'UCHAR', 'SHORT', 'USHORT',
               'INT', 'UINT', 'LONG', 'ULONG',
               'INVALID')
Sizes = {
    Formats.CHAR: 1,
    Formats.UCHAR: 1,
    Formats.SHORT: 2,
    Formats.USHORT: 2,
    Formats.INT: 4,
    Formats.UINT: 4,
    Formats.LONG: 8,
    Formats.ULONG: 8,
}


VERSION = '0.83'
METADATA_PATH = '/tmp/metadata.tmp.gz'
NEWBIN_POSTFIX = '_shuffled'
METADATA_POSTFIX = '.shuffle.bin'
METADESC_POSTFIX = '.meta.txt'
LOG_POSTFIX = '.log'
RAND_SECTION = '.rand'

OBJCOPY = spawn.find_executable("objcopy")
OBJCOPY_DUMPSEC = '--dump-section'
OBJCOPY_RMSEC   = '--remove-section'
NULL = '2> /dev/null'

# ELF Section names
SEC_TEXT      = '.text'
SEC_RODATA    = '.rodata'
SEC_DATA      = '.data'
SEC_DATA_REL  = '.data.rel.ro'
SEC_INIT_ARR  = '.init_array'
SEC_TM_CLONE  = '.tm_clone_table'
SEC_BSS       = '.bss'
SEC_REL_DYN   = '.rela.dyn'
SEC_REL_PLT   = '.rela.plt'
SEC_DYNSYM    = '.dynsym'
SEC_EH_FRAME  = '.eh_frame'
SEC_EH_FR_HDR = '.eh_frame_hdr'
SEC_SYMTAB    = '.symtab'
SEC_DEBUG_INFO= '.debug_info'

# Type definitions
BBL_TYPE   = {0: "BBL", 1: "FUN", 2: "OBJ"}
FIXUP_TYPE = {0: "C2C", 1: "C2D", 2: "D2C", 3: "D2D", 4: "NewSectionStart", 5: 'Special'}
SRC_TYPE   = {0: "C/C++", 1: "Inline Assembly", 2:"Standalone Assembly"}

SRC_TYPE_C, SRC_TYPE_INLINE, SRC_TYPE_ASSEMBLY = 0, 1, 2
FT_C2C, FT_C2D, FT_D2C, FT_D2D = 0, 1, 2, 3
FT_NewSec  = 4 # Fixup Type that new section begins
FT_Special = 5 # {".text.unlikely", ".text.exit", ".text.startup", ".text.hot"} section

DS_FIXUP_TEXT     = ['fixup_offset', 'fixup_deref_size',
                     'fixup_is_rela', 'fixup_type',
                     'fixup_num_jt_entries', 'fixup_jt_entry_sz']
DS_FIXUP_RODATA   = ['fixup_offset_ro', 'fixup_deref_size_ro',
                     'fixup_is_rela_ro', 'fixup_type_ro']
DS_FIXUP_DATA     = ['fixup_offset_data', 'fixup_deref_size_data',
                     'fixup_is_rela_data', 'fixup_type_data']
DS_FIXUP_DATAREL  = ['fixup_offset_datarel', 'fixup_deref_size_datarel',
                     'fixup_is_rela_datarel', 'fixup_type_datarel']
DS_FIXUP_INIT_ARR = ['fixup_offset_initarray', 'fixup_deref_size_initarray',
                     'fixup_is_rela_initarray', 'fixup_type_initarray']

WM_PERMUTATION_LEN = 58 # Watermark permutation lengh
WM_VALUE = '67556B58703273357638782F413F4428472B4B6250655368566D597133743677'

LOGO = """

                          ,...                                               
     .M'''bgd           .d' ""mm   `7MMM.     ,MMF'                `7MM      
    ,MI    "Y           dM`   MM     MMMb    dPMM                    MM      
    `MMb.      ,pW"Wq. mMMmmmmMMmm   M YM   ,M MM   ,6"Yb.  `7Mb,od8 MM  ,MP'
      `YMMNq. 6W'   `Wb MM    MM     M  Mb  M' MM  8)   MM    MM' "' MM ;Y   
    .     `MM 8M     M8 MM    MM     M  YM.P'  MM   ,pm9MM    MM     MM;Mm   
    Mb     dM YA.   ,A9 MM    MM     M  `YM'   MM  8M   MM    MM     MM `Mb. 
     "Ybmmd"   `Ybmd9'.JMML.  `Mbmo.JML. `'  .JMML.`Moo9^Yo..JMML. .JMML. YA.

                    * Watermark Embedder based on CCR * 

 Software Watermarking via a Binary Function Relocation
 (In the Annual Computer SEcurity Applications Conference 2021)
"""
