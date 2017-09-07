/** 
 * This class calculates the location of the target and communicate with the server.
 * @author  Sheng Wu
 * @version  1.0.0
 */

package org.sw.indoor_pos.algorithm;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.sw.indoor_pos.bean.BeaconInfo;
import org.sw.indoor_pos.bean.Location;
import org.sw.indoor_pos.server.Server; // should have a server class

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowCallbackHandler;

import Jama.Matrix;

public class WeightedTrilateral implements Dealer {
	private double totalWeight;
	private Location location;
	
	// DB instance
	// @Autowired
	private JdbcTemplate jdbcTemplate;
	
	@Override
	public Location getLocation(String str) {
		location = new Location();
		BeaconGroup doGrouper = new BeaconGroup();
		ArrayList<BeaconInfo> uniqueBeacons = doGrouper.doGroup(str);
		 
		if(uniqueBeacons == null){
			return null;
		}
		
		String maxRssiBeaconId = uniqueBeacons.get(0).getId();
		
		int roomId = this.jdbcTemplate.queryForObject("select room_id from base_station where base_id=" + maxRssiBeaconId, Integer.class);
		location.setRoomId(roomId);
		
		// terminal Id
		String[] str1 = str.split(";");
		String terminalId = str1[str1.length-1];
		
		String phoneId = this.jdbcTemplate.queryForObject("select phone_id from employee where terminal_id=" + terminalId, String.class);
		location.setPhoneId(phoneId);
		
		Integer[] beaconIDs = doGrouper.getBeaconIDs();
		CombinationAlgorithm ca = null;
		
		try {
			ca = new CombinationAlgorithm (beaconIDs, 3);
		} catch (Exception e) { 
			e.printStackTrace();
		}
		
		Object[][] c = ca.getResult();
		
		double[] tempLocation = new double[2];
		
		for(int i = 0; i<c.length; i++){
			List<BeaconInfo> triBeacons = new ArrayList<BeaconInfo>();		
			for(int j = 0; j<3; j++){
				BeaconInfo bb = uniqueBeacons.get((int) c[i][j]);
				triBeacons.add(bb);
			}
			
			double[] weightLocation = calculate(triBeacons);	
			tempLocation[0] += weightLocation[0];
			tempLocation[1] += weightLocation[1];
		}
		
		location.setxCoordinate(tempLocation[0]/totalWeight);
		location.setxCoordinate(tempLocation[1]/totalWeight);
		
		Timestamp ts = new Timestamp(System.currentTimeMillis());
		location.setTimeStamp(ts);		
		return location;
	}
	
	/**
	 * Calculate coordinates using weighted trilateral
	 * 
	 * @param  List<BeaconInfo> beacons: Note ids are different
	 * @return  double[]: coordinates
	 */
	public double[] calculate(List<BeaconInfo> beacons){
		/*id and coordinates of beacons*/
		final Map<String, double[]> beaconsLocation = new HashMap<String, double[]>();
		
		/*distances between target and 3 beacons*/
		double[] distanceArray = new double[3];
		
		String[] ids = new String[3];
		
		double[] rawLocation;
		
		// final coordinates
		double[] loc;
			
		/*Get envFactors from Server*/
		Double[] envFactors = Server.envFactors.get(location.getRoomId());
		
		// server needs to store a default envFactors
		if(envFactors == null){
			envFactors = Server.envFactors.get(0);
		}
		
		double height = envFactors[0];
		double n =  envFactors[1];
		double p0 =  envFactors[2];
		
		int j = 0;
		for (BeaconInfo beacon : beacons) {
			ids[j] = beacon.getId();
			distanceArray[j] = beacon.getDistance(height, n, p0);
			j++;
		}
		
		/*Get beacons info from database*/
		this.jdbcTemplate.query("select base_id,x_axis,y_axis from base_station where base_id in (?,?,?)",   
                new Object[] {ids[0],ids[1],ids[2]},   
                new RowCallbackHandler() {     
                    @Override    
                    public void processRow(ResultSet rs) throws SQLException {
                    	double[] loc1 = new double[2];
        				loc1[0] = rs.getDouble(2);
        				loc1[1] = rs.getDouble(3);
        				beaconsLocation.put(rs.getString(1), loc1);
                    }     
        });   
		
		int disArrayLength = distanceArray.length;
		
		double[][] a = new double[2][2];
		
		double[][] b = new double[2][1];
		
		/*initialization*/
		for(int i = 0; i < 2; i ++ ) {
 			a[i][0] = 2*(beaconsLocation.get(ids[i])[0] - beaconsLocation.get(ids[2])[0]);
			a[i][1] = 2*(beaconsLocation.get(ids[i])[1] - beaconsLocation.get(ids[2])[1]);
		}
		
		for(int i = 0; i < 2; i ++ ) {
			b[i][0] = Math.pow(beaconsLocation.get(ids[i])[0], 2) 
					- Math.pow(beaconsLocation.get(ids[2])[0], 2)
					+ Math.pow(beaconsLocation.get(ids[i])[1], 2)
					- Math.pow(beaconsLocation.get(ids[2])[1], 2)
					+ Math.pow(distanceArray[disArrayLength-1], 2)
					- Math.pow(distanceArray[i],2);
		}
		
		Matrix b1 = new Matrix(b);
		Matrix a1 = new Matrix(a);
		 
		Matrix a2  = a1.transpose();
		 
		Matrix tmpMatrix1 = a2.times(a1);
		Matrix reTmpMatrix1 = tmpMatrix1.inverse();
		Matrix tmpMatrix2 = reTmpMatrix1.times(a2);
		 
		Matrix resultMatrix = tmpMatrix2.times(b1);
		double[][] resultArray = resultMatrix.getArray();
		
		rawLocation = new double[2];
		
		for(int i = 0; i < 2; i++) {
			rawLocation[i] = resultArray[i][0];
		}
		 
		double weight = 0;
		
		for(int i = 0; i<3; i++){
			weight += (1.0/distanceArray[i]);
		}
		//weight+=(1.0/(distanceArray[0]+distanceArray[1]+distanceArray[2]));
		
		totalWeight += weight;
		 
		loc = new double[2];
		 
		for(int i = 0; i < 2; i++) {
			loc[i] = rawLocation[i]*weight;
		}
		return loc;
	}
}
