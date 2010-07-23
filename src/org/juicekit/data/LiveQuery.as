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

package org.juicekit.data {

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import org.juicekit.query.Query;

/**
 * Dispatched when data has been calculated.
 *
 * @eventType flash.events.Event
 */
[Event(name="complete", type="flash.events.Event")]


[Bindable]
/**
 * Allows an ArrayCollection of source data to be connected to a
 * flare Query such that the result of the flare Query is
 * continuously updated if the source data changes.    
 *
 */
public class LiveQuery extends DataBase {

  /**
   * Perform the query calculation
   * @return
   */
  override protected function doResult():Array {
    return query.eval(dataProvider.source);
  }

  /**
   * A Flare query to evaluate against the data in
   * <code>dataProvider</code>.
   *
   * @param q A Flare query
   */
  public function set query(q:Query):void {
    _query = q;
    setDirty();
    //var r:ArrayCollection = result;
  }


  public function get query():Query {
    return _query;
  }

  private var _query:Query = null;

  
  /**
   * Signal that result has changed and needs recalculation.
   * 
   * <p>Override to NOT dispatch a recalc event.</p>
   */
  override public function setDirty(e:Event = null):void {
    dirty = true;
  }


  /**
   * The timer limits LiveQuery recalculations to
   * once per <code>updateFrequency</code> milliseconds.
   *
   */
  private var timer:Timer;


  /**
   * Called each tick of the timer
   */
  private function onTick(event:TimerEvent):void {
    if (dirty && !recalcInProgress) {
      recalcInProgress = true;
      dispatchEvent(new Event(RECALC));
    }
  }

  
  /**
   * Set whether the LiveQuery recalculates.
   */
  public function set enabled(v:Boolean):void {
    if (v) {
      timer.start();
    } else {
      timer.stop();
    }
  }

  public function get enabled():Boolean {
    return timer.running;
  }

  /**
   * How frequently should this LiveQuery attempt to
   * recalculate in ms.
   *
   * <p>The default recalculation period is 100ms.</p>
   *
   */
  public function set updateFrequency(v:int):void {
    timer.delay = v;
  }

  /**
   * Constructor
   */
  public function LiveQuery() {
    timer = new Timer(100);
    timer.addEventListener(TimerEvent.TIMER, onTick);
    timer.start();
  }

}
}