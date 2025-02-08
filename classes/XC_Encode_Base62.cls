/**
    * @author Donato Lombardi - dolombardi@deloitte.it Pietro D'auria - pietro.dauria@nttdata.com
    * @description Base Encode 62
    * @param listNew - List WorkOrder
    * @return void
    **/
public with sharing class XC_Encode_Base62 {
/**
    * @author Donato Lombardi - dolombardi@deloitte.it Pietro D'auria - pietro.dauria@nttdata.com
    * @description Method to retrieve a Map of Work Order -> List skills requested
    * @param decimalValue - Decimal
    * @param outputNumberLength - Integer
    * @return OutputValue String
    **/
    public static String generateBase62(Decimal decimalValue, Integer outputNumberLength)
    {
        try
        {
            Integer inputBase = 10;
            Integer outputBase = 36;
            String outputValue = '';
            //String numericBaseData1 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
            String numericBaseData = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
            Integer x;
            Integer maxBase = NumericBaseData.length();
            if(DecimalValue == 0)
            {
                while(OutputValue.length() < outputNumberLength)
                {
                    OutputValue = '0' + OutputValue;
                }
                return OutputValue.left(4);
            }
            else
            {
                while(decimalValue > 0)
                {
                    X = (Integer)(((DecimalValue/outputBase) - (Integer)(DecimalValue/OutputBase))* OutputBase + 0.5);

                    OutputValue = NumericBaseData.subString(X,X+1)+OutputValue;
                    DecimalValue = Integer.valueOf(DecimalValue/OutputBase);

                }
            }

            while(OutputValue.length() < outputNumberLength)
            {
                OutputValue = '0' + OutputValue;
            }
            System.debug('ENCODE OUTPUT-->'+OutputValue );
            return OutputValue.left(4);
        }
        catch(Exception e)
        {
            System.debug('ERROR ECONDE--> '+ e);
            throw e;

        }

    }


}