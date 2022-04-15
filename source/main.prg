/*
** main.prg -- Apache harbour module V2
** (c) DHF, 2020-2021
** MIT license
*/

#define MODNAME			'mod_harbour.V2.1'
#define MODVERSION		'2.1.006'

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

#include "mh_apache.ch"

// ----------------------------------------------------------------//

function MH_ModName()

retu MODNAME

// ----------------------------------------------------------------//

function MH_ModVersion()

retu MODVERSION 

// ----------------------------------------------------------------//
