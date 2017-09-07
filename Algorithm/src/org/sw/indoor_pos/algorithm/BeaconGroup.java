/**
 * This class groups beacons in three using IDs.
 * Remove minimum and maximum RSSIs of each beacon and average the values.
 * @author  Sheng Wu
 * @version  1.0.0
 */

package org.sw.indoor_pos.algorithm;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.sw.indoor_pos.bean.BeaconInfo;
import org.sw.indoor_pos.bean.GroupSignalStrength;


public class BeaconGroup {	
	/*used in class Combination Algorithm*/
	private Integer[] beaconIDs; 

	public Integer[] getBeaconIDs() {
		return beaconIDs;
	}

	public void setBeaconIDs(Integer[] beaconIDs) {
		this.beaconIDs = beaconIDs;
	}
	
	/** 
	 * This method returns beacons that will be used in location calculation.
	 * @param  String str: a list of beacon information; Format: “id,rssi; id,rssi; ...; id,rssi; terminalID”
	 * @return  ArrayList<BeaconInfo> uniqueBeacons
	 */
	public ArrayList<BeaconInfo> doGroup(String str) {
		Map<String, GroupSignalStrength> groupedBeacons = group(str);
		
		/*Can't calculate if # of beacons < 3 in a group.*/
		if(groupedBeacons.size()<3) {
			return null; 
		}
		
		List<BeaconInfo> uniqueBeacons = dealByGroup(groupedBeacons);
		
		/*If number of received signals > 3, use the maximum three RSSIs.*/
		int len = uniqueBeacons.size();
		if(len>3) {
			Collections.sort(uniqueBeacons);
			return new ArrayList<BeaconInfo>(uniqueBeacons.subList(len-3, len));
		}
		
		return (ArrayList<BeaconInfo>) uniqueBeacons;
	}
	
	/** 
	 * This method takes in a string and group beacons using IDs.
	 * @param  String str: a list of beacons. Format: “id,rssi; id,rssi; ...; id,rssi; terminalID”
	 * @return  Map<String, GroupSignalStrength>
	 * 		    -- key: String beacon ID
	 * 			-- value: object <GroupSignalStrength>. Contains all RSSIs this beacon receives
	 */
	public Map<String, GroupSignalStrength> group(String str) {	
		Map<String, GroupSignalStrength> groupedBeacons = new HashMap<String, GroupSignalStrength>();
		
		// split different beacons. (id, rssi)
		String[] str1 = str.split(";");
		 
		// store beacon IDs
		Set<String> ids = new HashSet<String>();		
		for(int i=0; i<str1.length-1; i++) {
			ids.add(str1[i].split(",")[0]);
		}
		
		// store unique ids and all rssis it receives
		for(String id : ids){
			groupedBeacons.put(id, new GroupSignalStrength());
		}
		
		// add RSSIs to class GroupSignalStrength
		for(int i=0; i<str1.length-1; i++) {
			GroupSignalStrength group = groupedBeacons.get(str1[i].split(",")[0]);
			group.getRssis().add(Integer.parseInt(str1[i].split(",")[1]));
		}
		
		return groupedBeacons;
	}
	
	/**
	 * This method process data and return a list of ArrayList<BeaconInfo>.
	 * @param  Map<String, GroupSignalStrength> groups: grouped beacons using IDs 
	 * @return  ArrayList<BeaconInfo>
	 */
	public ArrayList<BeaconInfo> dealByGroup(Map<String, GroupSignalStrength> groups) {
		// rssi
		Integer r;
		List<BeaconInfo> beacons = new ArrayList<BeaconInfo>();
		int beaconNum = groups.size(); 
		beaconIDs = new Integer[beaconNum];	
		// for while loop and index of beaconIDs
		int k = 0;
		
		@SuppressWarnings("rawtypes")
		// key: id
		Iterator it = groups.keySet().iterator();
		
		while(it.hasNext()) { 		
			String id = (String) it.next(); 		
			GroupSignalStrength g = groups.get(id);  // return rssis of a beacon     
	        ArrayList<Integer> rssis = (ArrayList<Integer>) g.getRssis();
	        
	        int len = rssis.size();	        
	        int len2 = len/4;
	       
	        if(len >= 4) {
	        	int count = 0;
	        	for(int i=len2; i<len-len2; i++) {
					count += rssis.get(i);
				}
	        	r = count/(len-2*len2);
	        } else if(len == 1) {
		        r = rssis.get(0);
	        } else {
		        r = getMedian(rssis);
	        }
	        
	        BeaconInfo beacon = new BeaconInfo(id, r);
	        beacons.add(beacon);
 
	        beaconIDs[k] = k;
			k++;
		} 
		
		return (ArrayList<BeaconInfo>) beacons;	
	}
	
	/** 
	 * This method calculates the median of a list.
	 * @param  List<Integer> ls
	 * @return  Integer m
	 */
	public Integer getMedian(List<Integer> ls) {
		Integer m;
        Collections.sort(ls);
        
		if(ls.size()%2==0) {
        	m = (ls.get((ls.size()/2)-1) + ls.get(ls.size()/2)) / 2;
        } else {
        	m = (ls.get(ls.size()/2));
        }
		return m;
	}
}
