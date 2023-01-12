var WndLoading = null
//----------------------------------------------------------------------------//


function MsgInfo(cMsg, cTitle, cIcon, fCallback) {

   cTitle = (typeof cTitle) == 'string' ? cTitle : 'Information';
   cIcon = (typeof cIcon) == 'string' ? cIcon : '<i class="fas fa-info-circle"></i>';

   if (typeof cMsg !== 'string' || (typeof cMsg == 'string' && cMsg.length == 0))
      cMsg = String(cMsg)

   //	Check animations -> https://codepen.io/ghimawan/pen/vXYYOz?editors=0010#0

   var dialog = bootbox.dialog({
      title: cIcon + '&nbsp;' + cTitle,
      message: cMsg,
      size: 'medium',
      backdrop: false,
      onEscape: true,
      className: 'bounce fadeOut',
      buttons: {
         confirm: {
            label: '<i class="fa fa-check"></i> Accept',
            className: 'btn-outline-success',
            callback: function (result) {
               if (typeof fCallback === "function") {
                  fCallback.apply(null, [result]);
               }
            }
         }
      }
   });
}



//----------------------------------------------------------------------------//

function MsgError(cMsg, cTitle, cIcon, fCallback) {

   cTitle = (typeof cTitle) == 'string' ? cTitle : 'System Error';
   cIcon = (typeof cIcon) == 'string' ? cIcon : '<i class="fas fa-bug"></i>';

   if (typeof cMsg !== 'string' || (typeof cMsg == 'string' && cMsg.length == 0))
      cMsg = '&nbsp;'

   var dialog = bootbox.dialog({
      title: cIcon + '&nbsp;' + cTitle,
      message: cMsg,
      size: 'large',
      backdrop: false,
      onEscape: true,
      className: 'rubberBand animated',
      buttons: {
         cancel: {
            label: '<i class="fa fa-check"></i> Accept',
            className: 'btn-danger',
            callback: function (result) {

               if (typeof fCallback === "function") {
                  fCallback.apply(null, [result]);
               }
            }
         }
      }
   });
}

//----------------------------------------------------------------------------//

function MsgYesNo(cMsg, cTitle, cIcon, fCallback) {

   cTitle = (typeof cTitle) == 'string' ? cTitle : 'Information';
   cIcon = (typeof cIcon) == 'string' ? cIcon : '<i class="fas fa-bug"></i>';

   if (typeof cMsg !== 'string' || (typeof cMsg == 'string' && cMsg.length == 0))
      cMsg = '&nbsp;'


   bootbox.confirm({
      title: cTitle,
      message: cMsg,
      buttons: {
         cancel: {
            label: '<i class="fa fa-times"></i> Cancel'
         },
         confirm: {
            label: '<i class="fa fa-check"></i> Confirm'
         }
      },
      callback: function (result) {

         if (result && (typeof fCallback === "function")) {
            fCallback.apply(null, [result]);
         }
      }
   });

}


//----------------------------------------------------------------------------//
/*	Icons Animated
  "fas fa-spinner fa-spin"
  "fas fa-circle-notch fa-spin"
  "fas fa-sync fa-spin"
  "fas fa-cog fa-spin"
  "fas fa-spinner fa-pulse"
  "fas fa-stroopwafel fa-spin"
*/

function MsgLoading(cMessage, cTitle, cIcon, lHeader) {

   cMessage = (typeof cMessage) == 'string' ? cMessage : 'Loading...';
   cTitle = (typeof cTitle) == 'string' ? cTitle : 'System';
   cIcon = (typeof cIcon) == 'string' ? cIcon : '<i class="fas fa-sync fa-spin"></i>';
   lHeader = (typeof lHeader) == 'boolean' ? lHeader : false;

   var dialog = bootbox.dialog({
      title: cTitle,
      message: '<p>' + cIcon + '&nbsp;&nbsp;' + cMessage + '</p>',
      animate: false,
      //closeButton: false
   });

   dialog.addClass("loading_center");
   dialog.find("div.modal-content").addClass("loading_content");
   dialog.find("div.modal-body").addClass("loading_body");

   if (!lHeader)
      dialog.find("div.modal-header").addClass("loading_header");

   return dialog
}



//	MsgNotify --------------------------------------------------------------------------------------	
//	cType = 	success, info, danger, warning
//	Examples -> http://bootstrap-growl.remabledesigns.com/

function MsgNotify(cMsg, cType, lSound) {

   cType = (typeof cType == 'undefined') ? 'success' : cType;
   lSound = (typeof lSound == 'boolean') ? lSound : false;

   //	$.notify.defaults( { style: 'metro' );
   /*
      if ( lSound ) {
   	
         switch ( cType ) {
      	
            case 'success':
               TSound( _( '_sound_success' ) )
               break;		
      	
            case 'warn':
               TSound( _( '_sound_warn' ) )
               break;
            	
            case 'error':
               TSound( _( '_sound_error' ) )
               break;				
            	
            case 'info':
               TSound( _( '_sound_info' ) )
               break;									
         }		
      }
      */



   $.notify({ icon: "images/tweb.png", message: cMsg }, { type: cType, icon_type: 'image' });

}

//----------------------------------------------------------------------------//

function MsgSound(cFile) {

   var audioElement = document.createElement('audio');
   audioElement.setAttribute('src', cFile);
   audioElement.setAttribute('autoplay', 'autoplay');
}

//----------------------------------------------------------------------------//
function MsgLog(cMessage, cTitle) {

   cMessage = (typeof cMessage) == 'string' ? cMessage : ' ';
   cTitle = (typeof cTitle) == 'string' ? cTitle : '<i class="far fa-file-alt"></i>&nbsp;System Log';

   var cFile = "{{ TwebGlobal( 'path_log' ) }}"

   bootbox.dialog({
      size: 'large',
      title: cTitle,
      message: cFile,
      onEscape: true,
      buttons: {
         confirm: {
            label: '<i class="fa fa-check"></i> Accept'
         }
      }
   })
      .find(".modal-dialog").addClass("msg_dialog_log")
      .find(".modal-content").addClass("msg_content");

   return null
}


//----------------------------------------------------------------------------//


function HWIntro(cId, fFunction) {

   $("#" + cId).on('keyup', function (e) {
      if (e.key === 'Enter' || e.keyCode === 13) {
         if (typeof fFunction === "function") {
            fFunction.apply(null);
         }
      }
   });
}

//----------------------------------------------------------------------------//


function IsMobile() {

   var isMobile = false; //initiate as false
   // device detection
   if (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|ipad|iris|kindle|Android|Silk|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(navigator.userAgent)
      || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(navigator.userAgent.substr(0, 4))) {
      isMobile = true;
   }

   return isMobile
}

//----------------------------------------------------------------------------//

function MsgTask(cUrl, cKey, oValues, fCallback) {

   console.log('MsgTask() cUrl', cUrl)
   console.log('MsgTask() cKey', cKey)
   console.log('MsgTask() oValues', oValues)
   $body = $("body");
   $(document).on({
      ajaxStart: function () { $body.addClass("loading"); },
      ajaxStop: function () { $body.removeClass("loading"); }
   });

   var oPar = new Object()
   oPar['key'] = cKey

   if ($.type(oValues) == 'object') {
      oPar['values'] = JSON.stringify(oValues)
   } else {
      oPar['values'] = oValues
   };
   if (WndLoading == null) {
      WndLoading = MsgLoading();
   }
   $.post(cUrl, oPar, "", "text")
      .done(function (jdata, status) {
         try {
            var data = JSON.parse(jdata);
            if (data.error != "" && data.success === false) { //ERROR EN TIEMPO DE EJECUCION DE LA TASK
               MsgError(data.error);
               return;  //NO HACE CALLBACK
            } else {
               if (data.hasOwnProperty('info')) { //ERROR ENVIADO POR MsgInfo desde la task
                  MsgInfo(data.info);  //SI HACE CALLBACK EN CASO QUE TUVIERA
               };
            };
         } catch (e) { //ERROR EN COMPILACION DE LA TASK
            document.write(jdata);
            return; //NO HACE CALLBACK
         };
         if (typeof fCallback === "function") {
            fCallback.apply(null, [data]);
         } else {
            return (data);
         };
      })
      .fail(function (data) {
         console.log(data)
         alert(data.responseText)
      })
      .always(function () {
         if (WndLoading != null) {
            WndLoading.modal('hide');
            WndLoading = null;
         }
      });
};

//----------------------------------------------------------------------------//
//Todos los input que tengan el atributo tabindex="ord" estaran dentro del ciclo del Enter
$(document).ready(function () {
   $('input,button').on("keydown", function (e) {

      if (e.which == 13) {
         var tab = parseInt($(this).attr("tabindex")) + 1
         $("[tabindex=" + tab + "]").focus();
      }
   });
   $('.bootstrap-select').on("onclick", function (e) {
      if (e.which == 13) {
         var tab = parseInt($(this).attr("tabindex")) + 1
         $("[tabindex=" + tab + "]").focus();
      }
   });
});

//----------------------------------------------------------------------------//

function GetAutocomplete( cId, uSource, cSelect ) {

	var DatasetUrl = function ( request, response ) {
	
		$.ajax({
			url: uSource,
			data: { query: request.term },
			success: function(data){ 
				response(data);
			},
			error: function(jqXHR, textStatus, errorThrown){
				MsgError( jqXHR.responseText )
			},
			dataType: 'json',
			type: 'post'
		});		
	}	
	
	
	var oPar = new Object()			
		
		if  ( $.type( uSource ) == 'array' ) {
			oPar[ 'delay' ] = 10
			oPar[ 'source' ] = uSource
		} else {
			oPar[ 'delay' ] = 200
			oPar[ 'minLength' ] = 2
			oPar[ 'source' ] = DatasetUrl	
		}
		
	var fn = window[cSelect];

		if (typeof fn === "function") {	
			oPar[ 'select' ] = fn 
		}
		

	$( "#" + cId  ).autocomplete( oPar )
}

//----------------------------------------------------------------------------//

/*
 *
 * Copyright (c) 2006-2011 Sam Collett (http://www.texotela.co.uk)
 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 * 
 * Version 1.3.1
 * Demo: http://www.texotela.co.uk/code/jquery/numeric/
 *
 */
(function ($) {
   /*
    * Allows only valid characters to be entered into input boxes.
    * Note: fixes value when pasting via Ctrl+V, but not when using the mouse to paste
     *      side-effect: Ctrl+A does not work, though you can still use the mouse to select (or double-click to select all)
    *
    * @name     numeric
    * @param    config      { decimal : "." , negative : true }
    * @param    callback     A function that runs if the number is not valid (fires onblur)
    * @author   Sam Collett (http://www.texotela.co.uk)
    * @example  $(".numeric").numeric();
    * @example  $(".numeric").numeric(","); // use , as separator
    * @example  $(".numeric").numeric({ decimal : "," }); // use , as separator
    * @example  $(".numeric").numeric({ negative : false }); // do not allow negative values
    * @example  $(".numeric").numeric(null, callback); // use default values, pass on the 'callback' function
    * @example  $(".numeric").numeric({ scale: 2 }); // allow only two numbers after the decimal point.
    * @example  $(".numeric").numeric({ scale: 0 }); // Same as $(".numeric").numeric({ decimal : false });
    * @example  $(".numeric").numeric({ precision: 2 }); // allow only two numbers.
    * @example  $(".numeric").numeric({ precision: 4, scale: 2 }); // allow four numbers with two decimals. (99.99)
    *
    */
   $.fn.numeric = function (config, callback) {
      if (typeof config === 'boolean') {
         config = { decimal: config };
      }
      config = config || {};
      // if config.negative undefined, set to true (default is to allow negative numbers)
      if (typeof config.negative == "undefined") { config.negative = true; }
      // set decimal point
      var decimal = (config.decimal === false) ? "" : config.decimal || ".";
      // allow negatives
      var negative = (config.negative === true) ? true : false;
      // callback function
      callback = (typeof (callback) == "function" ? callback : function () { });
      // scale
      var scale;
      if ((typeof config.scale) == "number") {
         if (config.scale == 0) {
            decimal = false;
            scale = -1;
         }
         else
            scale = config.scale;
      }
      else
         scale = -1;
      // precision
      var precision;
      if ((typeof config.precision) == "number") {
         precision = config.precision;
      }
      else
         precision = 0;
      // set data and methods
      return this.data("numeric.decimal", decimal).data("numeric.negative", negative).data("numeric.callback", callback).data("numeric.scale", scale).data("numeric.precision", precision).keypress($.fn.numeric.keypress).keyup($.fn.numeric.keyup).blur($.fn.numeric.blur);
   };

   $.fn.numeric.keypress = function (e) {
      // get decimal character and determine if negatives are allowed
      var decimal = $.data(this, "numeric.decimal");
      var negative = $.data(this, "numeric.negative");
      // get the key that was pressed
      var key = e.charCode ? e.charCode : e.keyCode ? e.keyCode : 0;
      // allow enter/return key (only when in an input box)
      if (key == 13 && this.nodeName.toLowerCase() == "input") {
         return true;
      }
      else if (key == 13) {
         return false;
      }
      var allow = false;
      // allow Ctrl+A
      if ((e.ctrlKey && key == 97 /* firefox */) || (e.ctrlKey && key == 65) /* opera */) { return true; }
      // allow Ctrl+X (cut)
      if ((e.ctrlKey && key == 120 /* firefox */) || (e.ctrlKey && key == 88) /* opera */) { return true; }
      // allow Ctrl+C (copy)
      if ((e.ctrlKey && key == 99 /* firefox */) || (e.ctrlKey && key == 67) /* opera */) { return true; }
      // allow Ctrl+Z (undo)
      if ((e.ctrlKey && key == 122 /* firefox */) || (e.ctrlKey && key == 90) /* opera */) { return true; }
      // allow or deny Ctrl+V (paste), Shift+Ins
      if ((e.ctrlKey && key == 118 /* firefox */) || (e.ctrlKey && key == 86) /* opera */ ||
         (e.shiftKey && key == 45)) { return true; }
      // if a number was not pressed
      if (key < 48 || key > 57) {
         var value = $(this).val();
         /* '-' only allowed at start and if negative numbers allowed */
         if (value.indexOf("-") !== 0 && negative && key == 45 && (value.length === 0 || parseInt($.fn.getSelectionStart(this), 10) === 0)) { return true; }
         /* only one decimal separator allowed */
         if (decimal && key == decimal.charCodeAt(0) && value.indexOf(decimal) != -1) {
            allow = false;
         }
         // check for other keys that have special purposes
         if (
            key != 8 /* backspace */ &&
            key != 9 /* tab */ &&
            key != 13 /* enter */ &&
            key != 35 /* end */ &&
            key != 36 /* home */ &&
            key != 37 /* left */ &&
            key != 39 /* right */ &&
            key != 46 /* del */
         ) {
            allow = false;
         }
         else {
            // for detecting special keys (listed above)
            // IE does not support 'charCode' and ignores them in keypress anyway
            if (typeof e.charCode != "undefined") {
               // special keys have 'keyCode' and 'which' the same (e.g. backspace)
               if (e.keyCode == e.which && e.which !== 0) {
                  allow = true;
                  // . and delete share the same code, don't allow . (will be set to true later if it is the decimal point)
                  if (e.which == 46) { allow = false; }
               }
               // or keyCode != 0 and 'charCode'/'which' = 0
               else if (e.keyCode !== 0 && e.charCode === 0 && e.which === 0) {
                  allow = true;
               }
            }
         }
         // if key pressed is the decimal and it is not already in the field
         if (decimal && key == decimal.charCodeAt(0)) {
            if (value.indexOf(decimal) == -1) {
               allow = true;
            }
            else {
               allow = false;
            }
         }
      }
      //if a number key was pressed.
      else {
         // If scale >= 0, make sure there's only <scale> characters
         // after the decimal point.
         if ($.data(this, "numeric.scale") >= 0) {
            var decimalPosition = this.value.indexOf(decimal);
            //If there is a decimal.
            if (decimalPosition >= 0) {
               decimalsQuantity = this.value.length - decimalPosition - 1;
               //If the cursor is after the decimal.
               if ($.fn.getSelectionStart(this) > decimalPosition)
                  allow = decimalsQuantity < $.data(this, "numeric.scale");
               else {
                  integersQuantity = (this.value.length - 1) - decimalsQuantity;
                  //If precision > 0, integers and decimals quantity should not be greater than precision
                  if (integersQuantity < ($.data(this, "numeric.precision") - $.data(this, "numeric.scale")))
                     allow = true;
                  else
                     allow = false;
               }
            }
            //If there is no decimal
            else {
               if ($.data(this, "numeric.precision") > 0)
                  allow = this.value.replace($.data(this, "numeric.decimal"), "").length < $.data(this, "numeric.precision") - $.data(this, "numeric.scale");
               else
                  allow = true;
            }
         }
         else
            // If precision > 0, make sure there's not more digits than precision
            if ($.data(this, "numeric.precision") > 0)
               allow = this.value.replace($.data(this, "numeric.decimal"), "").length < $.data(this, "numeric.precision");
            else
               allow = true;
      }
      return allow;
   };

   $.fn.numeric.keyup = function (e) {
      var val = $(this).val();
      if (val && val.length > 0) {
         // get carat (cursor) position
         var carat = $.fn.getSelectionStart(this);
         // get decimal character and determine if negatives are allowed
         var decimal = $.data(this, "numeric.decimal");
         var negative = $.data(this, "numeric.negative");

         // prepend a 0 if necessary
         if (decimal !== "" && decimal !== null) {
            // find decimal point
            var dot = val.indexOf(decimal);
            // if dot at start, add 0 before
            if (dot === 0) {
               this.value = "0" + val;
            }
            // if dot at position 1, check if there is a - symbol before it
            if (dot == 1 && val.charAt(0) == "-") {
               this.value = "-0" + val.substring(1);
            }
            val = this.value;
         }

         // if pasted in, only allow the following characters
         var validChars = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, '-', decimal];
         // get length of the value (to loop through)
         var length = val.length;
         // loop backwards (to prevent going out of bounds)
         for (var i = length - 1; i >= 0; i--) {
            var ch = val.charAt(i);
            // remove '-' if it is in the wrong place
            if (i !== 0 && ch == "-") {
               val = val.substring(0, i) + val.substring(i + 1);
            }
            // remove character if it is at the start, a '-' and negatives aren't allowed
            else if (i === 0 && !negative && ch == "-") {
               val = val.substring(1);
            }
            var validChar = false;
            // loop through validChars
            for (var j = 0; j < validChars.length; j++) {
               // if it is valid, break out the loop
               if (ch == validChars[j]) {
                  validChar = true;
                  break;
               }
            }
            // if not a valid character, or a space, remove
            if (!validChar || ch == " ") {
               val = val.substring(0, i) + val.substring(i + 1);
            }
         }
         // remove extra decimal characters
         var firstDecimal = val.indexOf(decimal);
         if (firstDecimal > 0) {
            for (var k = length - 1; k > firstDecimal; k--) {
               var chch = val.charAt(k);
               // remove decimal character
               if (chch == decimal) {
                  val = val.substring(0, k) + val.substring(k + 1);
               }
            }
            // remove numbers after the decimal so that scale matches.
            if ($.data(this, "numeric.scale") >= 0)
               val = val.substring(0, firstDecimal + $.data(this, "numeric.scale") + 1);
            // remove numbers so that precision matches.
            if ($.data(this, "numeric.precision") > 0)
               val = val.substring(0, $.data(this, "numeric.precision") + 1);
         }
         // limite the integers quantity, necessary when user delete decimal separator
         else if ($.data(this, "numeric.precision") > 0)
            val = val.substring(0, ($.data(this, "numeric.precision") - $.data(this, "numeric.scale")));

         // set the value and prevent the cursor moving to the end
         this.value = val;
         $.fn.setSelection(this, carat);
      }
   };

   $.fn.numeric.blur = function () {
      var decimal = $.data(this, "numeric.decimal");
      var callback = $.data(this, "numeric.callback");
      var val = this.value;
      if (val !== "") {
         var re = new RegExp("^\\d+$|^\\d*" + decimal + "\\d+$");
         if (!re.exec(val)) {
            callback.apply(this);
         }
      }
   };

   $.fn.removeNumeric = function () {
      return this.data("numeric.decimal", null).data("numeric.negative", null).data("numeric.callback", null).unbind("keypress", $.fn.numeric.keypress).unbind("blur", $.fn.numeric.blur);
   };

   // Based on code from http://javascript.nwbox.com/cursor_position/ (Diego Perini <dperini@nwbox.com>)
   $.fn.getSelectionStart = function (o) {
      if (o.createTextRange) {
         var r = document.selection.createRange().duplicate();
         r.moveEnd('character', o.value.length);
         if (r.text === '') { return o.value.length; }
         return o.value.lastIndexOf(r.text);
      } else { return o.selectionStart; }
   };

   // set the selection, o is the object (input), p is the position ([start, end] or just start)
   $.fn.setSelection = function (o, p) {
      // if p is number, start and end are the same
      if (typeof p == "number") { p = [p, p]; }
      // only set if p is an array of length 2
      if (p && p.constructor == Array && p.length == 2) {
         if (o.createTextRange) {
            var r = o.createTextRange();
            r.collapse(true);
            r.moveStart('character', p[0]);
            r.moveEnd('character', p[1]);
            r.select();
         }
         else if (o.setSelectionRange) {
            o.focus();
            o.setSelectionRange(p[0], p[1]);
         }
      }
   };

})(jQuery);
