/*
** main.prg -- Apache harbour module V2
** (c) DHF, 2020-2021
** MIT license
*/

#define MODNAME			'mod_harbour.V2'
#define MODVERSION		'2.0a'

#ifdef __PLATFORM__WINDOWS
	#define __HBEXTERN__HBHPDF__REQUEST
	#include "..\contrib\hbhpdf\hbhpdf.hbx"
	#define __HBEXTERN__XHB__REQUEST
	#include "..\contrib\xhb\xhb.hbx"
	#define __HBEXTERN__HBCT__REQUEST
	#include "..\contrib\hbct\hbct.hbx"
	#define __HBEXTERN__HBWIN__REQUEST
	#include "..\contrib\hbwin\hbwin.hbx"
	#define __HBEXTERN__HBCURL__REQUEST
	#include "..\contrib\hbcurl\hbcurl.hbx"
	#define __HBEXTERN__HBZIPARC__REQUEST
	#include "..\contrib\hbziparc\hbziparc.hbx"
	#define __HBEXTERN__HBSSL__REQUEST
	#include "..\contrib\hbssl\hbssl.hbx"
	#define __HBEXTERN__HBMZIP__REQUEST
	#include "..\contrib\hbmzip\hbmzip.hbx"
	#define __HBEXTERN__HBNETIO__REQUEST
	#include "..\contrib\hbnetio\hbnetio.hbx"
#else
	#define __HBEXTERN__HBHPDF__REQUEST
	#include "./harbour/contrib/hbhpdf/hbhpdf.hbx"
	#define __HBEXTERN__XHB__REQUEST
	#include "./harbour/contrib/xhb/xhb.hbx"
	#define __HBEXTERN__HBCT__REQUEST
	#include "./harbour/contrib/hbct/hbct.hbx"
	#define __HBEXTERN__HBCURL__REQUEST
	#include "./harbour/contrib/hbcurl/hbcurl.hbx"
	#define __HBEXTERN__HBZIPARC__REQUEST
	#include "./harbour/contrib/hbziparc/hbziparc.hbx"
	#define __HBEXTERN__HBSSL__REQUEST
	#include "./harbour/contrib/hbssl/hbssl.hbx"
	#define __HBEXTERN__HBMZIP__REQUEST
	#include "./harbour/contrib/hbmzip/hbmzip.hbx"
	#define __HBEXTERN__HBNETIO__REQUEST
	#include "./harbour/contrib/hbnetio/hbnetio.hbx"
#endif


#include "mh_apache.ch"

// ----------------------------------------------------------------//

function MH_ModName()

retu MODNAME

// ----------------------------------------------------------------//

function MH_ModVersion()

retu MODVERSION 

// ----------------------------------------------------------------//
