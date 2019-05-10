public with sharing class  BitbucketRequest {
    
    public class BitbucketCommit extends BitbucketCallout implements ICommit{     
        
        private List<Attachment> sObj; 
        private String commitMessage;
        
        public override String getEndpoint(){
            final String uri = '/2.0/repositories/FlosumDemo/Flosum/src';
            return super.getBaseURL() + uri;
        }
        public override String getMethod(){  
            return 'POST';
        }
        public override String getBody(){
            return  BitbucketBuildReqBody.getstrBody(Zippex.unzipDeploymentManifests(sObj), this.commitMessage);
            // return null;
        }   
        public override Blob getBodyAsBlob(){
            //  List<Attachment> att=  Zippex.unzipDeploymentManifests(new List<Attachment>([SELECT id, Name, Body ,ParentId FROM Attachment WHERE id='00P1g000004cuC1']));
            //  return BitbucketBuildReqBody.getAttachmentsBodyasBlob(att,'Test deployment');
            return null;
        }  
        
        public void setData(List<sObject> data, String commitMessage){     
            this.sObj = (List<Attachment>)data;
            this.commitMessage=commitMessage;
        }
        public override void doProcess(){
            Http http = new Http();
            HttpRequest req = this.getRequest();
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
        public BitbucketCommit(){}
        
    }  
    
    public interface ICommit { 
        void setData(List<sObject> data,String commitMessage);
    }
    
    public abstract class BitbucketCallout {
        public abstract Blob getBodyAsBlob(); 
        public abstract String getBody();        
        public abstract String getEndpoint();
        public abstract String getMethod();
        public abstract void doProcess();
        
        public HttpRequest getRequest(){
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'multipart/form-data; boundary=' + UserInfo.getUserId());
            req.setEndpoint(this.getEndpoint());
            req.setMethod(this.getMethod()); 
            if(this.getBody() != null){
                req.setBody(this.getBody());
            } 
            if(this.getBodyAsBlob() != null){
                req.setBodyAsBlob(this.getBodyAsBlob());
            }
            req.setTimeout(100000); 
            system.debug(req);
            return req;
        }
        
        private String getBaseURL(){
            return 'callout:BitbucketDemo';
        }
    }
    
    public class BitbucketRequestException extends Exception {}
}