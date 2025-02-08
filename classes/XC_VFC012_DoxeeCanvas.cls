/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 26/08/2019
* @date Modification 
* @description XC_VFC012_DoxeeCanvas - Custom controller for the vf page XC_VFP012_DoxeeCanvas
*/

public class XC_VFC012_DoxeeCanvas {

    private final Individual ind;

    private final String country;
    private final String company;

    /**
     * @description the constructor
     * @param stdController the standard controller
     */
    public XC_VFC012_DoxeeCanvas(ApexPages.StandardController stdController) {
        this.ind = (Individual)stdController.getRecord();

        String info = XC_LCC066_Doxee.getUserInformation(ind.id);
        XC_LCC066_Doxee.WrapperUser wrInfo = (XC_LCC066_Doxee.WrapperUser) JSON.deserialize(info, XC_LCC066_Doxee.WrapperUser.class);
        this.country = wrInfo.country;
        this.company = wrInfo.company;
    }

    /**
     * @description get the country 
     * @return the country
     */
    public String getCountry() {
        return country;
    }

    /**
     * @description get the company 
     * @return the company
     */
    public String getCompany() {
        return company;
    }
    
}