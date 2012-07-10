!++
!   DESCRIP.MMS
!
!   Description file for building MMK.
!   Copyright (c) 2008, Matthew Madison.
!   Copyright (c) 2012, Endless Software Solutions.
!
!   All rights reserved.
!
!   Redistribution and use in source and binary forms, with or without
!   modification, are permitted provided that the following conditions
!   are met:
!
!       * Redistributions of source code must retain the above
!         copyright notice, this list of conditions and the following
!         disclaimer.
!       * Redistributions in binary form must reproduce the above
!         copyright notice, this list of conditions and the following
!         disclaimer in the documentation and/or other materials provided
!         with the distribution.
!       * Neither the name of the copyright owner nor the names of any
!         other contributors may be used to endorse or promote products
!         derived from this software without specific prior written
!         permission.
!
!   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
!   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
!   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
!   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
!   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
!   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
!   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
!   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
!   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
!   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
!   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!       
!   28-SEP-1993	V1.0	Madison	    Initial commenting.
!   25-JUL-1994	V1.1	Madison	    Update for V3.2.
!   27-DEC-1998	V1.2	Madison	    Update for V3.8.
!   03-MAY-2004 V1.3    Madison     Integrate IA64 support.
!   03-MAR-2008 V2.0    Madison     Cleanup for open-source release.
!   05-JUL-2009 V2.1    Sneddon     Added HTML documentation.
!   16-APR-2010 V2.2	Sneddon     New modules, etc.
!--

.IFDEF ARCH
.ELSE
.IFDEF MMS$ARCH_NAME
ARCH = $(MMS$ARCH_NAME)
.ELSE
.ERROR You must define the ARCH macro as one of: VAX, ALPHA, IA64
.ENDIF
.ENDIF

.IFDEF __MADGOAT_BUILD__
MG_FACILITY = MMK
SRCDIR = MG_SRC:[MMK]
BINDIR = MG_BIN:[MMK]
ETCDIR = MG_ETC:[MMK]
KITDIR = MG_KIT:[MMK]
.ELSE
SRCDIR = SYS$DISK:[]
BINDIR = SYS$DISK:[.BIN-$(ARCH)]
ETCDIR = SYS$DISK:[.ETC-$(ARCH)]
KITDIR = SYS$DISK:[.KIT-$(ARCH)]
.ENDIF
.FIRST
    @ IF F$PARSE("$(BINDIR)") .EQS. "" THEN CREATE/DIR $(BINDIR)
    @ DEFINE/NOLOG BIN_DIR $(BINDIR)
    @ IF F$PARSE("$(ETCDIR)") .EQS. "" THEN CREATE/DIR $(ETCDIR)
    @ DEFINE/NOLOG ETC_DIR $(ETCDIR)
    @ IF F$PARSE("$(KITDIR)") .EQS. "" THEN CREATE/DIR $(KITDIR)
    @ DEFINE/NOLOG KIT_DIR $(KITDIR)
    @ IF F$SEARCH("DISK$COMMON:[FREEWARE60.SDL]SDL.COM") .NES. "" -
	THEN @DISK$COMMON:[FREEWARE60.SDL]SDL.COM
    @ IF F$TRNLNM("MMK_SDL_SETUP") .NES. "" -
	THEN @MMK_SDL_SETUP:

OPT = .$(ARCH)_OPT
MMKCOPT = MMK_COMPILE_RULES$(OPT)

SDL = SDL/VAX

.IFDEF DBG
CFLAGS = $(CFLAGS)/DEBUG/NOOPT/LIST=$(ETCDIR)
.IFDEF __VAX__
CFLAGS = $(CFLAGS)/MACHINE=AFTER
.ELSE
CFLAGS = $(CFLAGS)/MACHINE
.ENDIF
LINKFLAGS = $(LINKFLAGS)/TRACEBACK
.ENDIF

!
! Modules for building MMK
!
OBJECTS = MMK=$(BINDIR)MMK.OBJ,FILEIO=$(BINDIR)FILEIO.OBJ,-
          MEM=$(BINDIR)MEM.OBJ,GET_RDT=$(BINDIR)GET_RDT.OBJ,-
          SP_MGR=$(BINDIR)SP_MGR.OBJ,MISC=$(BINDIR)MISC.OBJ,-
          OBJECTS=$(BINDIR)OBJECTS.OBJ,SYMBOLS=$(BINDIR)SYMBOLS.OBJ,-
          READDESC=$(BINDIR)READDESC.OBJ,-
          BUILD_TARGET=$(BINDIR)BUILD_TARGET.OBJ,-
          PARSE_DESCRIP=$(BINDIR)PARSE_DESCRIP.OBJ,-
          CMS_INTERFACE=$(BINDIR)CMS_INTERFACE.OBJ,-
          PARSE_OBJECTS=$(BINDIR)PARSE_OBJECTS.OBJ,-
          PARSE_TABLES=$(BINDIR)PARSE_TABLES.OBJ,-
          MMK_MSG=$(BINDIR)MMK_MSG.OBJ,MMK_CLD=$(BINDIR)MMK_CLD.OBJ,-
          DEFAULT_RULES=$(BINDIR)DEFAULT_RULES.OBJ
!
! Modules for building the rules compiler
!
MMKCMODS = FILEIO=$(BINDIR)FILEIO.OBJ,MEM=$(BINDIR)MEM.OBJ,-
           MISC=$(BINDIR)MISC.OBJ,OBJECTS=$(BINDIR)OBJECTS.OBJ,-
           SYMBOLS=$(BINDIR)SYMBOLS.OBJ,-
           READDESC=$(BINDIR)READDESC.OBJ,-
           PARSE_DESCRIP=$(BINDIR)PARSE_DESCRIP.OBJ,-
           PARSE_OBJECTS=$(BINDIR)PARSE_OBJECTS.OBJ,-
           PARSE_TABLES=$(BINDIR)PARSE_TABLES.OBJ,-
           MMK_MSG=$(BINDIR)MMK_MSG.OBJ

CFLAGS = /NODEBUG$(CFLAGS)$(DEFINE)
LINKFLAGS = /NOTRACEBACK/NODEBUG$(LINKFLAGS)

$(BINDIR)MMK.EXE : $(BINDIR)MMK.OLB($(OBJECTS)),$(SRCDIR)MMK$(OPT)
    $(LIBR)/COMPRESS/OUTPUT=$(BINDIR)MMK.OLB $(BINDIR)MMK.OLB
    $(LINK)$(LINKFLAGS) $(SRCDIR)MMK$(OPT)/OPT

MMK_H	    	    	    = $(SRCDIR)MMK.H, $(ETCDIR)MMK_MSG.H

$(BINDIR)MMK.OBJ            : $(SRCDIR)MMK.C,$(MMK_H)
$(BINDIR)MEM.OBJ            : $(SRCDIR)MEM.C,$(MMK_H)
$(BINDIR)SP_MGR.OBJ         : $(SRCDIR)SP_MGR.C,$(MMK_H)
$(BINDIR)FILEIO.OBJ         : $(SRCDIR)FILEIO.C,$(MMK_H)
$(BINDIR)GET_RDT.OBJ	    : $(SRCDIR)GET_RDT.C,$(MMK_H)

$(BINDIR)SYMBOLS.OBJ        : $(SRCDIR)SYMBOLS.C,$(MMK_H),$(SRCDIR)GLOBALS.H
$(BINDIR)OBJECTS.OBJ        : $(SRCDIR)OBJECTS.C,$(MMK_H),$(SRCDIR)GLOBALS.H
$(BINDIR)MISC.OBJ           : $(SRCDIR)MISC.C,$(MMK_H),$(SRCDIR)GLOBALS.H
$(BINDIR)READDESC.OBJ       : $(SRCDIR)READDESC.C,$(MMK_H),$(SRCDIR)GLOBALS.H
$(BINDIR)BUILD_TARGET.OBJ   : $(SRCDIR)BUILD_TARGET.C,$(MMK_H),$(SRCDIR)GLOBALS.H
$(BINDIR)PARSE_DESCRIP.OBJ  : $(SRCDIR)PARSE_DESCRIP.C,$(MMK_H),$(SRCDIR)GLOBALS.H
$(BINDIR)PARSE_OBJECTS.OBJ  : $(SRCDIR)PARSE_OBJECTS.C,$(MMK_H),$(SRCDIR)GLOBALS.H
$(BINDIR)CMS_INTERFACE.OBJ  : $(SRCDIR)CMS_INTERFACE.C,-
                              $(MMK_H),$(SRCDIR)CMSDEF.H,$(SRCDIR)GLOBALS.H
$(BINDIR)PARSE_TABLES.OBJ   : $(SRCDIR)PARSE_TABLES.MAR
    $(MACRO)$(MFLAGS) SYS$LIBRARY:ARCH_DEFS.MAR+$(SRCDIR)PARSE_TABLES.MAR

$(BINDIR)DEFAULT_RULES.OBJ  : $(SRCDIR)DEFAULT_RULES.C,$(MMK_H),$(SRCDIR)GLOBALS.H,-
                              $(ETCDIR)MMK_DEFAULT_RULES.H

$(BINDIR)MMK_MSG.OBJ        : $(SRCDIR)MMK_MSG.MSG
$(BINDIR)MMK_CLD.OBJ        : $(SRCDIR)MMK_CLD.CLD

$(ETCDIR)MMK_MSG.H	    : $(SRCDIR)MMK_MSG.MSG
    $(MESSAGE)/NOOBJECT/SDL=$(ETCDIR)MMK_MSG.SDL $(MMS$SOURCE)
    $(SDL)/LANGUAGE=CC=$(MMS$TARGET) $(ETCDIR)MMK_MSG.SDL

$(ETCDIR)MMK_DEFAULT_RULES.H : $(SRCDIR)MMK_DEFAULT_RULES_$(ARCH).MMS, $(BINDIR)MMK_COMPILE_RULES.EXE
    MMKC := $$(BINDIR)MMK_COMPILE_RULES.EXE
    MMKC/OUTPUT=$(MMS$TARGET) $(MMS$SOURCE)

MMKCOBJ = $(BINDIR)MMK_COMPILE_RULES.OBJ,$(BINDIR)GENSTRUC.OBJ,$(BINDIR)MMK_COMPILE_RULES_CLD.OBJ

$(BINDIR)MMK_COMPILE_RULES_CLD.OBJ : $(SRCDIR)MMK_COMPILE_RULES_CLD.CLD

$(BINDIR)MMK_COMPILE_RULES.EXE : $(MMKCOBJ),$(BINDIR)MMK.OLB($(MMKCMODS)),$(MMKCOPT)
    $(LINK)$(LINKFLAGS) $(MMKCOBJ),$(SRCDIR)$(MMKCOPT)/opt

$(BINDIR)MMK_COMPILE_RULES.OBJ	: $(SRCDIR)MMK_COMPILE_RULES.C,$(MMK_H)
$(BINDIR)GENSTRUC.OBJ	       	: $(SRCDIR)GENSTRUC.C,$(MMK_H),$(SRCDIR)GLOBALS.H

!
! The help file
!
$(KITDIR)MMK_HELP.HLP : $(SRCDIR)MMK_HELP.RNH

!
! Documentation
!
DOCS : $(KITDIR)MMK_DOC.PS,$(KITDIR)MMK_DOC.TXT,$(KITDIR)MMK_DOC.HTML,-
	$(KITDIR)MMK_HELP.HLP
$(KITDIR)MMK_DOC.PS : $(SRCDIR)MMK_DOC.SDML,$(SRCDIR)MMK_DEFAULT_RULES_VAX.MMS,-
                      $(SRCDIR)MMK_DEFAULT_RULES_ALPHA.MMS,$(SRCDIR)MMK_DEFAULT_RULES_IA64.MMS
    @ IF F$TRNLNM("DECC$SHR") .NES. "" THEN DEF/USER DECC$SHR SYS$SHARE:DECC$SHR
    DOCUMENT/CONTENTS/NOPRINT/DEVICE=BLANK_PAGES/OUTPUT=$(MMS$TARGET) $(MMS$SOURCE) SOFTWARE.REFERENCE PS
$(KITDIR)MMK_DOC.TXT : $(SRCDIR)MMK_DOC.SDML,$(SRCDIR)MMK_DEFAULT_RULES_VAX.MMS,,-
                       $(SRCDIR)MMK_DEFAULT_RULES_ALPHA.MMS,$(SRCDIR)MMK_DEFAULT_RULES_IA64.MMS
    @ IF F$TRNLNM("DECC$SHR") .NES. "" THEN DEF/USER DECC$SHR SYS$SHARE:DECC$SHR
    DOCUMENT/CONTENTS/NOPRINT/OUTPUT=$(MMS$TARGET) $(MMS$SOURCE) SOFTWARE.REFERENCE MAIL
$(KITDIR)MMK_DOC.HTML : $(SRCDIR)MMK_DOC.SDML,$(SRCDIR)MMK_DEFAULT_RULES_VAX.MMS,,-
                       $(SRCDIR)MMK_DEFAULT_RULES_ALPHA.MMS,$(SRCDIR)MMK_DEFAULT_RULES_IA64.MMS
    @ IF F$TRNLNM("DECC$SHR") .NES. "" THEN DEF/USER DECC$SHR SYS$SHARE:DECC$SHR
    DOCUMENT/CONTENTS/OUTPUT=$(KITDIR) $(MMS$SOURCE) SOFTWARE.REFERENCE HTML

CLEAN :
    - DELETE $(ETCDIR)*.*;*
    - DELETE $(BINDIR)*.*;*

REALCLEAN : CLEAN
    - DELETE $(KITDIR)*.*;*

.IFDEF ZIP
.ELSE
ZIP = ZIP
.ENDIF

KIT : $(KITDIR)MMK.ZIP
    @ !

$(KITDIR)MMK.ZIP : DISTRIBUTION, SOURCE
    IF F$SEARCH("$(MMS$TARGET)") .NES. "" THEN DELETE $(MMS$TARGET);*
    olddef = F$ENV("DEFAULT")
    SET DEFAULT DIST_ROOT:[DIST]
    - PURGE *.*
    $(ZIP)/VMS DIST_ROOT:[000000]MMK.ZIP *.*;
    SET DEFAULT 'olddef'
    - DELETE DIST_ROOT:[DIST]*.*;*
    - SET PROTECTION=O:RWED $(KITDIR)DIST.DIR;
    - DELETE $(KITDIR)DIST.DIR;

DISTRIBUTION : $(SRCDIR)AAAREADME.DOC,AAAREADME.TOO,AAAREADME.INSTALL,LICENSE.TXT
    olddef = F$ENV("DEFAULT")
    IF "$(KITDIR)" .NES. "" THEN SET DEFAULT $(KITDIR)
    IF F$SEARCH("DIST.DIR") .NES. "" THEN DELETE [.DIST]*.*;*
    IF F$SEARCH("DIST.DIR") .NES. "" THEN SET PROTECTION=O:RWED DIST.DIR
    IF F$SEARCH("DIST.DIR") .NES. "" THEN DELETE DIST.DIR;
    CREATE/DIRECTORY [.DIST]
    SET DEFAULT 'olddef
    ROOT = F$PARSE("$(KITDIR)DIST.DIR",,,"DEVICE","NO_CONCEAL")+F$PARSE("$(KITDIR)DIST.DIR",,,"DIRECTORY","NO_CONCEAL")-"]["-"]"+".]"
    DEFINE DIST_ROOT 'ROOT'/TRANSLATION=CONCEAL
    PURGE $(MMS$SOURCE_LIST)
    BACKUP $(MMS$SOURCE_LIST) DIST_ROOT:[DIST]/OWNER=PARENT

SOURCE : $(SRCDIR)MMK.C,FILEIO.C,MEM.C,GET_RDT.C,SP_MGR.C,-
    	 MISC.C,OBJECTS.C,SYMBOLS.C,READDESC.C,BUILD_TARGET.C,PARSE_DESCRIP.C,-
    	 PARSE_OBJECTS.C,PARSE_TABLES.MAR,MMK_MSG.MSG,MMK_CLD.CLD,-
    	 MMK.H,GLOBALS.H,MMK_MSG.H,CMSDEF.H,CMS_INTERFACE.C,-
    	 CLIDEFS.H,DESCRIP.MMS,MMK.VAX_OPT,MMK.ALPHA_OPT,-
         MMK.IA64_OPT,MMK_COMPILE_RULES.IA64_OPT,MMK_DEFAULT_RULES_IA64.MMS,-
    	 MMK_COMPILE_RULES.C,GENSTRUC.C,DEFAULT_RULES.C,MMK_COMPILE_RULES.VAX_OPT,-
    	 MMK_COMPILE_RULES.ALPHA_OPT,MMK_COMPILE_RULES_CLD.CLD,-
    	 MMK_DEFAULT_RULES_VAX.MMS,MMK_DEFAULT_RULES_ALPHA.MMS,-
    	 MMK_HELP.RNH,MMK_DOC.SDML,COMPILE.COM
    PURGE $(MMS$SOURCE_LIST)
    BACKUP $(MMS$SOURCE_LIST) DIST_ROOT:[DIST]/OWNER=PARENT
