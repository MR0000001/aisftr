/**
* @author Federico Amici - federico.amici@nttdata.com, Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 29/05/2019
* @date Modification dd/mm/yyyy
* @description Data factory for the NE__Matrix_Parameter__c object
*/

@isTest
public class XC_DF_MatrixParameter {
    
    /**
    * @author Federico Amici - federico.amici@nttdata.com, Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 29/05/2019
    * @date Modification dd/mm/yyyy
    * @description Creates matrix paramter
    */
    public static List<NE__Matrix_Parameter__c> createMatrixParameter(Integer numMatrix) {

        Integer counter = numMatrix;
        List<NE__Matrix_Parameter__c> listMat = new List<NE__Matrix_Parameter__c>();
        NE__Matrix_Parameter__c mat;

        while(counter > 0) {
            mat = new NE__Matrix_Parameter__c();
            mat.Name = 'eHome_SPA_SetPrice' + counter;
            listMat.add(mat);
            counter--;
        }

        return listMat;
    }

    /**
    * @author Federico Amici - federico.amici@nttdata.com, Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 29/05/2019
    * @date Modification dd/mm/yyyy
    * @description Creates matrix paramter rows
    */
    public static List<NE__Matrix_Parameter_Row__c> createMatrixParameterRows(NE__Matrix_Parameter__c mat,
                                                                             List<Asset> listAsset, 
                                                                             List<NE__Product__c> listProducts,
                                                                             String paymentModel) {

        List<NE__Matrix_Parameter_Row__c> listMatrixRows = new List<NE__Matrix_Parameter_Row__c>();
        NE__Matrix_Parameter_Row__c row;

        for(Asset a : listAsset) {
            row = new NE__Matrix_Parameter_Row__c();
            row.XC_Rule_Type__c = 'Pricing';
            row.XC_Value1__c = 'Bandoleiro';
            row.Product_LIC_Name__c = listProducts[0].Name;
            row.XC_Payment_Model__c = paymentModel;
            row.XC_Region__c = 'Peninsula';
            row.NE__Matrix_Parameter__c = mat.Id;
            row.XC_Offline_Name_07__c = 'Penalización_3Y_00M_06M (€)';
            row.XC_Offline_Value_07__c = String.valueOf(1300 - (Integer.valueOf(Math.random() * 50)));
            row.XC_Offline_Name_08__c = 'Penalización_3Y_06M_12M (€)';
            row.XC_Offline_Value_08__c = String.valueOf(900 - (Integer.valueOf(Math.random() * 50)));
            row.XC_Offline_Name_09__c = 'Penalización_3Y_12M_18M (€)';
            row.XC_Offline_Value_09__c = String.valueOf(700 - (Integer.valueOf(Math.random() * 50)));
            row.XC_Offline_Name_10__c = 'Penalización_3Y_18M_24M (€)';
            row.XC_Offline_Value_10__c = String.valueOf(600 - (Integer.valueOf(Math.random() * 50)));
            row.XC_Offline_Name_11__c = 'Penalización_3Y_24M_30M (€)';
            row.XC_Offline_Value_11__c = String.valueOf(500 - (Integer.valueOf(Math.random() * 50)));
            row.XC_Offline_Name_12__c = 'Penalización_3Y_30M_36M (€)';
            row.XC_Offline_Value_12__c = String.valueOf(400 - (Integer.valueOf(Math.random() * 50)));
            row.XC_Offline_Name_13__c = 'Desinstalación (€)';
            row.XC_Offline_Value_13__c = '666';
            row.XC_Offline_Name_14__c = 'Pen_Unistall (€)';
            row.XC_Offline_Value_14__c = '600';
            row.XC_Offline_Name_15__c = 'otp_3Y_00M_06M (€)';
            row.XC_Offline_Value_15__c = String.valueOf(1300 - (Integer.valueOf(Math.random() * 50)));
            row.XC_Offline_Name_16__c = 'otp_3Y_06M_12M (€)';
            row.XC_Offline_Value_16__c = String.valueOf(900 - (Integer.valueOf(Math.random() * 50)));
            row.XC_Offline_Name_17__c = 'otp_3Y_12M_18M (€)';
            row.XC_Offline_Value_17__c = String.valueOf(700 - (Integer.valueOf(Math.random() * 50)));
            row.XC_Offline_Name_18__c = 'otp_3Y_18M_24M (€)';
            row.XC_Offline_Value_18__c = String.valueOf(600 - (Integer.valueOf(Math.random() * 50)));
            row.XC_Offline_Name_19__c = 'otp_3Y_24M_30M (€)';
            row.XC_Offline_Value_19__c = String.valueOf(500 - (Integer.valueOf(Math.random() * 50)));
            row.XC_Offline_Name_20__c = 'otp_3Y_30M_36M (€)';
            row.XC_Offline_Value_20__c = String.valueOf(400 - (Integer.valueOf(Math.random() * 50)));
            row.NE__Start_Date__c = Date.today().addDays(-10);
            listMatrixRows.add(row);
        }

        return listMatrixRows;

    }

}