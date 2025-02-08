/**
  * @description XC_TR_Configuration_U_GenerateOTP
  */
public class XC_TR_Configuration_U_GenerateOTP {
    /**
     *@description  Generate OTP.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void generateOTP(List<NE__Order__c> listNew, Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew) {
        List<NE__Order__c> orderToUpdate = new List<NE__Order__c>();
        for(NE__Order__c conf : listNew) {
             if(conf.XC_OTPCode__c == null){
                 conf.XC_OTPCode__c = generateRandomNumber();
                 
             }
         }
    }
    
	/**
	 *@description Generate random number.
	 *
	 * @return the string
	 */
	public static String generateRandomNumber(){ 
		String otp = String.valueOf(Math.abs(Crypto.getRandomInteger()));
        return otp.substring(0,5);
	}

}