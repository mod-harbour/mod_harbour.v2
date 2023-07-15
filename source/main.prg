/*
** main.prg -- Apache harbour module V2
** (c) DHF, 2020-2021
** MIT license
*/

#define MODNAME 'mod_harbour.V2.1'
#define MODVERSION '2.1.013'

#ifdef __PLATFORM__WINDOWS
   #define __HBEXTERN__HBWIN__REQUEST
   #include "../hbwin/hbwin.hbx"
#endif

#define __HBEXTERN__HBHPDF__REQUEST
#include "../hbhpdf/hbhpdf.hbx"
#define __HBEXTERN__XHB__REQUEST
#include "../xhb/xhb.hbx"
#define __HBEXTERN__HBCT__REQUEST
#include "../hbct/hbct.hbx"
#define __HBEXTERN__HBCURL__REQUEST
#include "../hbcurl/hbcurl.hbx"
#define __HBEXTERN__HBZIPARC__REQUEST
#include "../hbziparc/hbziparc.hbx"
#define __HBEXTERN__HBSSL__REQUEST
#include "../hbssl/hbssl.hbx"
#define __HBEXTERN__HBMZIP__REQUEST
#include "../hbmzip/hbmzip.hbx"
#define __HBEXTERN__HBNETIO__REQUEST
#include "../hbnetio/hbnetio.hbx"
#define __HBEXTERN__HBMISC__REQUEST
#include "../hbmisc/hbmisc.hbx" 
#ifdef HB_WITH_ADS
   #define __HBEXTERN__RDDADS__REQUEST
   #include "../rddads/rddads.hbx"
#endif
#ifdef HB_WITH_TDOLPHIN
   #define __HBEXTERN__TDOLPHIN__REQUEST
   #include "../tdolphin/tdolphin.hbx"
#endif  
#ifdef HB_WITH_LETODB
   #define __HBEXTERN__RDDLETO__REQUEST
   #include "../letodb/rddleto.hbx"
#endif   
#ifdef HB_WITH_LETODBF
   #define __HBEXTERN__LETODB__REQUEST
   #include "../letodbf/letodb.hbx"
#endif   
#ifdef HB_WITH_LIBMONGOC
   #define __HBEXTERN__HBMONGOC__REQUEST
   #include "../hbmongoc/hbmongoc.hbx"
#endif   
#ifdef HB_WITH_PGSQL
   #define __HBEXTERN__HBPGSQL__REQUEST
   #include "../hbpgsql/hbpgsql.hbx"
#endif   
#ifdef HB_WITH_ZEBRA
#define __HBEXTERN__HBZEBRA__REQUEST
#include "../hbzebra/hbzebra.hbx"
#endif   

#include "mh_apache.ch"

// ----------------------------------------------------------------//

function MH_ModName()

retu MODNAME

// ----------------------------------------------------------------//

function MH_ModVersion()

retu MODVERSION 