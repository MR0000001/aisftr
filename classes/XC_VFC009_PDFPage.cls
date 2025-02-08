/**
* @author Monica Cutillo - mcutillo@deloitte.it
* @date Creation 02/03/2020
* @date Modification 
* @description XC_VFC009_PDFPage - Custom controller for the vf page XC_VFP009_PDFPage
*/
    public class XC_VFC009_PDFPage {
	
    /* @description the PDFData */
    public String PDFData {get; set;}
	
    /* @description the sourcePDFData */
    public String sourcePDFData {get; set;} 
    
    /* @description Costructor */
    public XC_VFC009_PDFPage(){
        PDFData = '';
        sourcePDFData = '';
    }
    
    /* @description downloadPDF */
    public PageReference downloadPDF(){
        System.PageReference pageRef = new System.PageReference('/apex/PDFGenerator');
    
        //ensure pdf downloads and is assigned with defined name
        pageRef.getHeaders().put('content-disposition', 'attachment; filename=InvoicePDF.pdf');
     
        return pageRef;
    }
}