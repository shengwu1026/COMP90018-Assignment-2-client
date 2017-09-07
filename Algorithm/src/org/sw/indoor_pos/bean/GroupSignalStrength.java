/**  
 * This class keeps a list of RSSIs of a beacon.
 * @author  Sheng Wu
 * @version  1.0.0
 */

package org.sw.indoor_pos.bean;

import java.util.ArrayList;
import java.util.List;

public class GroupSignalStrength {
	private List<Integer> rssis = new ArrayList<Integer>();

	public List<Integer> getRssis() {
		return rssis;
	}

	public void setRssis(List<Integer> rssis) {
		this.rssis = rssis;
	}
}
