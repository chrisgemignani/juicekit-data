/*
 * Copyright 2007-2010 Juice, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.adobe.serialization.json {

/**
 * @private
 */
public class JSONEncoder {

  /** The string that is going to represent the object we're encoding */
  private var jsonString:String;

  /**
   * Creates a new JSONEncoder.
   *
   * @param o The object to encode as a JSON string
   * @langversion ActionScript 3.0
   * @playerversion Flash 8.5
   * @tiptext
   */
  public function JSONEncoder(o:Object) {
    jsonString = convertToString(o);

  }

  /**
   * Gets the JSON string from the encoder.
   *
   * @return The JSON string representation of the object
   *     that was passed to the constructor
   * @langversion ActionScript 3.0
   * @playerversion Flash 8.5
   * @tiptext
   */
  public function getString():String {
    return jsonString;
  }

  /**
   * Converts a value to it's JSON string equivalent.
   *
   * @param value The value to convert.  Could be any
   *    type (object, number, array, etc)
   */
  private function convertToString(value:Object):String {

    // determine what value is and convert it based on it's type
    if (value is String) {

      // escape the string so it's formatted correctly
      return escapeString(value as String);

    } else if (value is Number) {

      // only encode numbers that finate
      return isFinite(value as Number) ? value.toString() : "null";

    } else if (value is Boolean) {

      // convert boolean to string easily
      return value ? "true" : "false";

    } else if (value is Array) {

      // call the helper method to convert an array
      return arrayToString(value as Array);

    } else if (value is Object && value != null) {

      // call the helper method to convert an object
      return objectToString(value);
    }
    return "null";
  }

  /**
   * Escapes a string accoding to the JSON specification.
   *
   * @param str The string to be escaped
   * @return The string with escaped special characters
   *     according to the JSON specification
   */
  private function escapeString(str:String):String {
    // create a string to store the string's jsonstring value
    var s:String = "";
    // current character in the string we're processing
    var ch:String;
    // store the length in a local variable to reduce lookups
    var len:Number = str.length;

    // loop over all of the characters in the string
    for (var i:int = 0; i < len; i++) {

      // examine the character to determine if we have to escape it
      ch = str.charAt(i);
      switch (ch) {

        case '"':  // quotation mark
          s += "\\\"";
          break;

        //case '/':	// solidus
        //	s += "\\/";
        //	break;

        case '\\':  // reverse solidus
          s += "\\\\";
          break;

        case '\b':  // bell
          s += "\\b";
          break;

        case '\f':  // form feed
          s += "\\f";
          break;

        case '\n':  // newline
          s += "\\n";
          break;

        case '\r':  // carriage return
          s += "\\r";
          break;

        case '\t':  // horizontal tab
          s += "\\t";
          break;

        default:  // everything else

          // check for a control character and escape as unicode
          if (ch < ' ') {
            // get the hex digit(s) of the character (either 1 or 2 digits)
            var hexCode:String = ch.charCodeAt(0).toString(16);

            // ensure that there are 4 digits by adjusting
            // the # of zeros accordingly.
            var zeroPad:String = hexCode.length == 2 ? "00" : "000";

            // create the unicode escape sequence with 4 hex digits
            s += "\\u" + zeroPad + hexCode;
          } else {

            // no need to do any special encoding, just pass-through
            s += ch;

          }
      }	// end switch

    }	// end for loop

    return "\"" + s + "\"";
  }

  /**
   * Converts an array to it's JSON string equivalent
   *
   * @param a The array to convert
   * @return The JSON string representation of <code>a</code>
   */
  private function arrayToString(a:Array):String {
    // create a string to store the array's jsonstring value
    var s:String = "";

    // loop over the elements in the array and add their converted
    // values to the string
    for (var i:int = 0; i < a.length; i++) {
      // when the length is 0 we're adding the first element so
      // no comma is necessary
      if (s.length > 0) {
        // we've already added an element, so add the comma separator
        s += ","
      }

      // convert the value to a string
      s += convertToString(a[i]);
    }

    // KNOWN ISSUE:  In ActionScript, Arrays can also be associative
    // objects and you can put anything in them, ie:
    //		myArray["foo"] = "bar";
    //
    // These properties aren't picked up in the for loop above because
    // the properties don't correspond to indexes.  However, we're
    // sort of out luck because the JSON specification doesn't allow
    // these types of array properties.
    //
    // So, if the array was also used as an associative object, there
    // may be some values in the array that don't get properly encoded.
    //
    // A possible solution is to instead encode the Array as an Object
    // but then it won't get decoded correctly (and won't be an
    // Array instance)

    // close the array and return it's string value
    return "[" + s + "]";
  }

  /**
   * Converts an object to it's JSON string equivalent
   *
   * @param o The object to convert
   * @return The JSON string representation of <code>o</code>
   */
  private function objectToString(o:Object):String {

    // create a string to store the object's jsonstring value
    var s:String = "";

    // the value of o[key] in the loop below - store this
    // as a variable so we don't have to keep looking up o[key]
    // when testing for valid values to convert
    var value:Object;

    // loop over the keys in the object and add their converted
    // values to the string
    for (var key:String in o) {
      // assign value to a variable for quick lookup
      value = o[key];

      // don't add function's to the JSON string
      if (value is Function) {
        // skip this key and try another
        continue;
      }

      // when the length is 0 we're adding the first item so
      // no comma is necessary
      if (s.length > 0) {
        // we've already added an item, so add the comma separator
        s += ","
      }

      s += escapeString(key) + ":" + convertToString(value);
    }

    return "{" + s + "}";
  }

}

}
