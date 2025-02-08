/**
  * @description 
  */
public class XC_Handler_Canvas_DoxeeConnectedApp implements Canvas.CanvasLifecycleHandler { 
   
    /** The Constant urlCanvasAgreementBra. */ 
    public static final String URLCANVASAGREEMENTBRA =         Label.ATCL_urlCanvasAgreementBra;
    
    /** The Constant urlCanvasCancelAgreementBra. */
    public static final String URLCANVASCANCELAGREEMENTBRA =   Label.ATCL_urlCanvasCancelAgreementBra;
    
    /** The Constant urlCanvasgetAgreementBra. */ 
    public static final String URLCANVASGETAGREEMENTBRA =      Label.ATCL_urlCanvasgetAgreementBra;
    
    /** The Constant urlCanvasBillingAdjusdmentBra. */
    public static final String URLCANVASBILLINGADJUSDMENTBRA = Label.ATCL_urlCanvasBillingAdjusdmentBra;

    /**
     * Exclude context types. 
     * @description 
     * @return the sets the 
     */
    public Set<Canvas.ContextTypeEnum> excludeContextTypes(){
        Set<Canvas.ContextTypeEnum> excluded = new Set<Canvas.ContextTypeEnum>();
        return excluded;
    }

    /**
     * On render.
     * @description
     * @param renderContext the render context
     */
    public void onRender(Canvas.RenderContext renderContext) {
        Canvas.ApplicationContext app = renderContext.getApplicationContext();
        Canvas.EnvironmentContext env = renderContext.getEnvironmentContext();    
        // get urlpath from canvas app
        String newURL = getURLPath(app.getCanvasUrl());
        //Canvas APP Name
        System.debug('getName: '+app.getName());
        //URLs canvas Brasil
        System.debug('urlCanvasCancelAgreementBra: '    +urlCanvasCancelAgreementBra);
        System.debug('urlCanvasAgreementBra: '          +urlCanvasAgreementBra);
        System.debug('urlCanvasgetAgreementBra: '       +urlCanvasgetAgreementBra);
        System.debug('urlCanvasBillingAdjusdmentBra: '  +urlCanvasBillingAdjusdmentBra);

        System.debug('env.getParametersAsJSON(): ' + env.getParametersAsJSON() );     
        String canvasMode = env.getParametersAsJSON();
        if(canvasMode!=null){
            if(canvasMode.contains('rebilling')){
                newURL = getURLPath(urlCanvasBillingAdjusdmentBra);
                System.debug('Url Canvas atcl.rebilling= ' + newURL);
            }else if(canvasMode.contains('getAgreement')){
                newURL = getURLPath(urlCanvasgetAgreementBra);
                System.debug('Url Canvas getAgreement= ' + urlCanvasgetAgreementBra);
            }else if(canvasMode.contains('createAgreement')){
                newURL = getURLPath(urlCanvasAgreementBra);
                System.debug('Url Canvas createAgreement= ' + urlCanvasAgreementBra);  
            }else if(canvasMode.contains('cancelAgreement')){
                newURL = getURLPath(urlCanvasCancelAgreementBra);
                System.debug('Url Canvas cancelAgreement= ' + urlCanvasCancelAgreementBra);
            }else{
                System.debug('Canvas no encontrado');
            }
        }else{
            System.debug('Parámetros Canvas no encontrados');
        }

        //update the url
        app.setCanvasUrlPath(newURL);
        System.debug('app.getCanvasUrl(): ' + app.getCanvasUrl());
    }

    /**
     * Gets the URL path.
     * @description
     * @param canvasURL the canvas URL
     * @return the URL path
     */
    private string getURLPath(string canvasURL){
        String[] urlList = canvasUrl.split('/');
        string urlPath = '';
        for(Integer a = 3; a < urlList.size(); a++){
            urlPath += '/' + urlList[a];
        }
        return urlPath;
    } 
}