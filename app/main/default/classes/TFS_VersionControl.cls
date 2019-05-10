public class TFS_VersionControl {

   public class TFSCommit extends TFSCallout implements ICommit{     
        
        private List<Attachment> sObj; 
        private String commitMessage;
        
        public override String getEndpoint(){
            final String uri = '/ibegei/versionControl/_apis/tfvc/changesets?api-version=5.0';
            return super.getBaseURL() + uri;
        }
        public override String getMethod(){  
            return 'POST';
        }
        public override String getBody(){
           
            return  TFSCommitReqBody.getBody(Zippex.unzipDeploymentManifests(sObj), this.commitMessage);
           
        }   
 
        
        public void setData(List<sObject> data, String commitMessage){     
            this.sObj = (List<Attachment>)data;
            this.commitMessage=commitMessage;
        }
        public override void doProcess(){
            Http http = new Http();
            HttpRequest req = this.getRequest();
            req.setHeader('Authorization', '{!$Credential.Password}');
            try{
                HttpResponse resp = http.send(req);
                system.debug(resp.getStatus());
                system.debug(resp.getStatusCode());
                system.debug(resp.getBody());
                if(resp.getStatusCode() == 200) { 
                    
                } else {
                    
                }
            } catch (Exception ex){
                System.debug('Exception on callout: '+ex.getMessage());
                System.debug('Stack Trace:' + ex.getStackTraceString());
            } finally {
                
            }
        }
        public TFSCommit(){}
        
    }  
    
    public interface ICommit { 
        void setData(List<sObject> data,String commitMessage);
    }
    
    public abstract class TFSCallout {
      
        public abstract String getBody();        
        public abstract String getEndpoint();
        public abstract String getMethod();
        public abstract void doProcess();
        
        public HttpRequest getRequest(){
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(this.getEndpoint());
            req.setMethod(this.getMethod()); 
            if(this.getBody() != null){
                req.setBody(this.getBody());
            } 

            req.setTimeout(100000); 
            system.debug(req);
            return req;
        }
              

        
        private String getBaseURL(){
            return 'callout:TFSDemo';
        }
    }
    
    public class TFSRequestException extends Exception {}
}