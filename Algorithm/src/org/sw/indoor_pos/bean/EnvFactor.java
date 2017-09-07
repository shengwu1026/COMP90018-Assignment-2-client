/**
 * This class stores information of env factors.
 * @author  Sheng Wu
 * @version  1.0.0
 */

package org.sw.indoor_pos.bean;

import java.io.Serializable;

public class EnvFactor implements Serializable{
	
	private static final long serialVersionUID = 1L;
	private Integer roomId;	
	private Double height;
	/*pass loss*/
	private Double n;
	/*rssi from 1m away*/
	private Double p0;
	
	public EnvFactor(Integer roomId, Double height, Double n, Double p0) {
		super();
		this.roomId = roomId;
		this.height = height;
		this.n = n;
		this.p0 = p0;
	}
	
	public EnvFactor() {
		super();
	}

	public Integer getRoomId() {
		return roomId;
	}

	public void setRoomId(Integer roomId) {
		this.roomId = roomId;
	}

	public Double getHeight() {
		return height;
	}

	public void setHeight(Double height) {
		this.height = height;
	}

	public Double getN() {
		return n;
	}

	public void setN(Double n) {
		this.n = n;
	}

	public Double getP0() {
		return p0;
	}

	public void setP0(Double p0) {
		this.p0 = p0;
	}
}