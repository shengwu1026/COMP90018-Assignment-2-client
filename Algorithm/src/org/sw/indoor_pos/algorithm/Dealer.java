/** 
 * This class is the interface to outside. Class WeightedTrilateral implements the interface.
 * @author  Sheng Wu
 * @version  1.0.0
 */

package org.sw.indoor_pos.algorithm;

import org.sw.indoor_pos.bean.Location;

public interface Dealer {
	/**
	 * @param  str  Format: “id,rssi; id,rssi; ...; id,rssi; terminalID”
	 * @return  coordinates
	 */
	public Location getLocation(String str);
}