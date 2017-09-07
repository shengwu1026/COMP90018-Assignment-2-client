/** 
 * @author Sheng Wu
 * @version 1.0.0
 */

package org.sw.indoor_pos.algorithm;

public class CombinationAlgorithm { 
    private int listLength;
    private int elementNo;
    private int objRowIndex;
    public Object[][] obj;
    
    public CombinationAlgorithm(Object[] list, int no2Pick) throws Exception {
        if (list == null) throw new Exception("List is null");
        if (list.length < no2Pick) throw new Exception("Number of elements exceeds the list length");
        listLength = list.length;
        elementNo = no2Pick;
        objRowIndex = 0;
        obj = new Object[combination(listLength, elementNo)][elementNo];
        Object[] tmp = new Object[elementNo];
        combine(list, 0, 0, elementNo, tmp);
    }

    /**
     * Calculate C(m,n) = (m!)/(n!*(m-n)!) 
     * @param m
     * @param n
     * @return C(m,n) 
     */
    public int combination(int m, int n) {
        if (m < n)
            return 0; 

        int k = 1;
        int j = 1;
      
        for (int i = n; i >= 1; i--) {
            k = k * m;
            j = j * n;
            m--;
            n--;
        }
        return k / j;
    }
    
    /** 
     * @param Object list
     * @param int listIndex
     * @param int i 
     * @param Object[] tmp
     */
    private void combine(Object list[], int listIndex, int i, int n, Object[] tmp) {
        int j;
        for (j = listIndex; j < list.length - (n - 1); j++) {
            tmp[i] = list[j];
            if (n == 1) {
                System.arraycopy(tmp, 0, obj[objRowIndex], 0, tmp.length);
                objRowIndex ++;
            } else {
                n--;
                i++;
                combine(list, j+1, i, n, tmp);
                n++;
                i--;
            }
        }
    }

    public Object[][] getResult() {
        return obj;
    }
}
