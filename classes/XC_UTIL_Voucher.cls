/**
* @author
* @date
* @date 
* @description 
*/


public class XC_UTIL_Voucher {


    /**
    * @author
    * @date
    * @date 
    * @description 
    * @param numberOfCoupon
    * @return Set<String>
    */  
    public static Set<String> generateCouponCode(Integer numberOfCoupon) {
        
        /*List<String> stringCode = ('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz').split('');
        if (stringCode.get(0).equals('')) {
            stringCode.remove(0);
        }
        Set<String> returnSet = new Set<String>();
        while (returnSet.size() < numberOfCoupon) {

            String returnCode = '';
            DateTime now = DateTime.now();

            Integer y1 = now.year() / 62; 
            Integer y2 = Math.mod(now.year(), 62);

            Integer ms1 = now.millisecond() / 62;
            Integer ms2 = Math.mod(now.millisecond(), 62);

            returnCode = stringCode.get(y1) + stringCode.get(y2) + stringCode.get(now.month()) + stringCode.get(now.day()) + stringCode.get(now.hour())
                        + stringCode.get(now.minute()) + stringCode.get(now.second()) + stringCode.get(ms1) + stringCode.get(ms2)+ math.round( ( math.random() * 100 ) < 10  ? math.random() * 100 + 10 : math.random() * 100 );
            if (!returnSet.contains(returnCode)) {
                returnSet.add(returnCode);
            }
        }*/


        // Generazione coupon solo maiuscole + valori random
        List<String> stringCode = ('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789ABCDEFGHIJKLMNOP').split(''); //size stringCode: 62, restartIndex: 36
        if (stringCode.get(0).equals('')) {
            stringCode.remove(0);
        }
        Integer stringCodeSize = 62;
        Integer restartIndex = 36;
        List<String> saltedStringCodeA = ('0123456789ABCDEFGH').split('');
        if(saltedStringCodeA.get(0).equals('')) {
            saltedStringCodeA.remove(0);
        }
        List<String> saltedStringCodeB = ('IJKLMNOPQRSTUVWXYZ').split('');
        if (saltedStringCodeB.get(0).equals('')) {
            saltedStringCodeB.remove(0);
        }

        Set<String> returnSet = new Set<String>();
        Set<String> returnSetWithoutSalt = new Set<String>();
        while (returnSet.size() < numberOfCoupon) {

            String returnCode = '';
            DateTime now = DateTime.now();

            String year = stringCode.get(Math.mod(now.year(), stringCodeSize)); //1984 mod 62 = 0 -> '0' , 2010 mod 62 = 26 -> 'Q' , 2019 mod 62 = 36 -> '0' , 2022 mod 62 = 38 -> '2'
            String month = stringCode.get(now.month());                         //valori da 0 a 12 -> da '0' a 'C'
            String day = stringCode.get(now.day());                             //valori da 0 a 31 -> da '0' a 'V'
            String hour = stringCode.get(now.hour());                           //valori da 0 a 23 -> da '0' a 'N'
            String minute = stringCode.get(now.minute());                       //valori da 0 a 59 -> da '0' a 'N' a 'N' (ricomincia da capo da posizione 36 in poi)
            String minuteSalt = saltedStringCodeA.get(Integer.valueof((Math.random() * saltedStringCodeA.size()-1))); //random value from saltedStringCodeA
            if(now.minute() >= restartIndex) { //random value from saltedStringCodeB
                minuteSalt = saltedStringCodeB.get(Integer.valueof((Math.random() * saltedStringCodeB.size()-1)));
            }
            String second = stringCode.get(now.second()); //valori da 0 a 59 -> da '0' a 'N' a 'N' (ricomincia da capo da posizione 36 in poi)
            String secondSalt = saltedStringCodeA.get(Integer.valueof((Math.random() * saltedStringCodeA.size()-1))); //random value from saltedStringCodeA
            if(now.second() >= restartIndex) { //random value from saltedStringCodeB
                secondSalt = saltedStringCodeB.get(Integer.valueof((Math.random() * saltedStringCodeB.size()-1)));
            }
            String ms1 = stringCode.get(now.millisecond() / stringCodeSize);
            String ms2 = stringCode.get(Math.mod(now.millisecond(), stringCodeSize));

            returnCode = year + month + day + hour + minute + second + ms1 + ms2;
            
            if (!returnSetWithoutSalt.contains(returnCode)) {
                returnSetWithoutSalt.add(returnCode);
               
                String saltedString = minuteSalt + year + month + secondSalt + hour + minute + second + ms1 + ms2 + day;
                Blob saltedBlob = Blob.valueOf(saltedString);
                Blob cryptedSaltedBlob = Crypto.generateDigest('SHA-256', saltedBlob);
                String finalCouponCode = EncodingUtil.convertToHex(cryptedSaltedBlob).toUpperCase().substring(0, 10); 
                returnSet.add(finalCouponCode);
                System.debug('@@@ finalCouponCode: ' + finalCouponCode);
            }
        }

        System.debug('@@@ returnSet: ' + returnSet);
        return returnSet;
    }


    /**
    * @author Martina Barone - marbarone@deloitte.it & Giulio Serra - giserra@deloitte.it
    * @date Creation 25/10/2018
    * @date Modification dd/mm/yyyy
    * @description  createNvoucherFromSingleVoucher - generate a number of voucher from a father according to the XC_Voucher_To_Be_Created__c field
    * @return List<XC_Voucher__c>
    * @param  toClone 
    */    
    public static List<XC_Voucher__c> createNvoucherFromSingleVoucher(XC_Voucher__c toClone){

        List<XC_Voucher__c> voucherList = new List<XC_Voucher__c>();
        List<String> codes = new List<String>(XC_Util_Voucher.generateCouponCode(toClone.XC_Voucher_To_Be_Created__c.intValue()-1));
        
        if(toClone.XC_Voucher_To_Be_Created__c > 1){

            for(Integer i=0; i<codes.size(); i++){
                
               String generatedCode = codes.get(i); 
               XC_Voucher__c clone = toClone.clone(false,true,false,true); // deep copy of father voucher
              
               Integer value = i+2;
               String newName = toClone.Name.replace('1', String.valueOf(value)); 

               System.debug('new name ' + newName);
               clone.Name = newName;
              clone.XC_Voucher_To_Be_Created__c = 1;
               clone.XC_VoucherCode__c = generatedCode;
               voucherList.add(clone);  

            }
        }

        return voucherList;
    }

}