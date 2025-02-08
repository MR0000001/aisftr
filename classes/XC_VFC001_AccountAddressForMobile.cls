/**
 * @description The Class XC_VFC001_AccountAddressForMobile.
 */
public class XC_VFC001_AccountAddressForMobile {

    /** @description The acct. */
    private final Account acct;

    /**
     * @description The extension constructor initializes the private member variable acct by using the getRecord method from the standard. 
     * Instantiates a new x C VFC 001 account address for mobile.
     * @param stdController the std controller
     */
    // controller.
    public XC_VFC001_AccountAddressForMobile(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
    }

}