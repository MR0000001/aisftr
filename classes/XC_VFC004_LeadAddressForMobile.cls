/**
 * @description The Class XC_VFC004_LeadAddressForMobile.
 */
public class XC_VFC004_LeadAddressForMobile {
     
     /** The ld. */
     private final Lead ld;
    
    /**
     * @description The extension constructor initializes the private member variable ld by using the getRecord method from the standard.
     * Instantiates a new x C VFC 004 lead address for mobile.
     *
     * @param stdController the std controller
     */
    // controller.
    public XC_VFC004_LeadAddressForMobile(ApexPages.StandardController stdController) {
        this.ld = (Lead)stdController.getRecord();
    }

}