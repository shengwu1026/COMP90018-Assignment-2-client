/**  
 * This class keeps the information of a beacon, including String string(ID), int rssi, and a serialUID. 
 * Methods include getDistance and comapreTo (compare RSSIs).
 * @author  Sheng Wu
 * @version  1.0.0
 */

package org.sw.indoor_pos.bean; 

import java.io.Serializable;

public class BeaconInfo implements Comparable<BeaconInfo>, Serializable {
	
	private static final long serialVersionUID = 1L;
	
	/* beacon id*/
	private String id;  
	
	/* strength of received signal*/
	private Integer rssi;  
	
	public BeaconInfo(String string, int rssi) {
		this.id = string;
		this.rssi =  rssi;
	}
	
	public String getId() {
		return id;
	}
	
	public void setId(String id) {
		this.id = id;
	}
	
	public Integer getRssi() {
		return rssi;
	}
	
	public void setRssi(Integer rssi) {
		this.rssi = rssi;
	}
	
	public double getDistance(double height, double n, double p0){		
		/*the distance between the beacon and phone*/
		double rawDistance;
		rawDistance = Math.pow(10, (p0-rssi)/(10*n));
		
		/*the horizontal distance between the beacon and phone*/
		return Math.sqrt(Math.pow(rawDistance, 2) - Math.pow(height, 2));
	}
	
	@Override
	public int compareTo(BeaconInfo beacon) { 
		if(rssi > beacon.rssi) {
			return 1;
		} else {
			return -1;
		}
	}
	
	@Override
	public String toString() { 
		return "Beacon ID: " + id+ " , and the strength is：" + rssi;
	}
}

