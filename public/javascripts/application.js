// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
/**
 * Written by Rob Schmitt, The Web Developer's Blog
 * http://webdeveloper.beforeseven.com/
 */

/**
 * The following variables may be adjusted
 */
var active_color = '#000'; // Colour of user provided text
var inactive_color = '#bbb'; // Colour of default text

/**
 * No need to modify anything below this line
 */
window.onload = formDefaultValues;

function formDefaultValues() {
  var fields = getElementsByClassName(document, "input", "default-value");
  if (!fields) {
    return;
  }
  var default_values = new Array();
  for (var i = 0; i < fields.length; i++) {
    fields[i].style.color = inactive_color;
    if (!default_values[fields[i].id]) {
      default_values[fields[i].id] = fields[i].value;
    }
    fields[i].onfocus = function() {
      if (this.value == default_values[this.id]) {
        this.value = '';
        this.style.color = active_color;
      }
      this.onblur = function() {
        if (this.value == '') {
          this.style.color = inactive_color;
          this.value = default_values[this.id];
        }
      }
    }
  }
}

/**
 * getElementsByClassName()
 * Written by Jonathan Snook, http://www.snook.ca/jonathan
 * Add-ons by Robert Nyman, http://www.robertnyman.com
*/

function getElementsByClassName(oElm, strTagName, strClassName){
  var arrElements = (strTagName == "*" && oElm.all)? oElm.all : oElm.getElementsByTagName(strTagName);
  var arrReturnElements = new Array();
  strClassName = strClassName.replace(/\-/g, "\\-");
  var oRegExp = new RegExp("(^|\\s)" + strClassName + "(\\s|$)");
  var oElement;
  for (var i = 0; i < arrElements.length; i++) {
    oElement = arrElements[i];
    if (oRegExp.test(oElement.className)) {
      arrReturnElements.push(oElement);
    }
  }
  return (arrReturnElements);
}