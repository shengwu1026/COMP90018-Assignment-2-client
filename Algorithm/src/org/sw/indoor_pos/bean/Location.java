/**
 * This class keeps a record of location, including String phoneId, Integer roomId, 
 * Double xCoordinate, Double yCoordinate, Timestamp timeStamp, and a final serialUID.
 * @author  Sheng Wu
 * @version  1.0.0
 */

package org.sw.indoor_pos.bean;

import java.io.Serializable;
import java.sql.Timestamp;


public class Location implements Serializable {
	
	private static final long serialVersionUID = 1L;
 
	private String phoneId;
	private Integer roomId;
	private Double xCoordinate;
	private Double yCoordinate;
	private Timestamp timeStamp;

	public Location(String phoneId, Integer roomId, Double xCoordinate, Double yCoordinate, Timestamp timeStamp) {
		super(); 
		this.phoneId = phoneId;
		this.roomId = roomId;
		this.xCoordinate = xCoordinate;
		this.yCoordinate = yCoordinate;
		this.timeStamp = timeStamp;
	}

	public Location() {
		super();
	}

	public String getPhoneId() {
		return phoneId;
	}

	public void setPhoneId(String phoneId) {
		this.phoneId = phoneId;
	}
	
	public Integer getRoomId() {
		return roomId;
	}

	public void setRoomId(Integer roomId) {
		this.roomId = roomId;
	}
 
	public Double getxCoordinate() {
		return xCoordinate;
	}

	public void setxCoordinate(Double xCoordinate) {
		this.xCoordinate = xCoordinate;
	}

	public Double yCoordinate() {
		return yCoordinate;
	}

	public void setyCoordinate(Double yCoordinate) {
		this.yCoordinate = yCoordinate;
	}

	public Timestamp getTimeStamp() {
		return timeStamp;
	}

	public void setTimeStamp(Timestamp timeStamp) {
		this.timeStamp = timeStamp;
	}

	@Override
	public String toString() {
		return  phoneId + "is at "+ xCoordinate + "," + yCoordinate + "at" + timeStamp;
	}
}

