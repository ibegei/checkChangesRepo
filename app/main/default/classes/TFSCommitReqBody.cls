public class TFSCommitReqBody {
    public static String getBody(List<Attachment> attachments , String commitMessage){
        CommitReq req=new CommitReq();
        req.comment=commitMessage;
        req.changes=new List<Change>();
        for(Attachment att:attachments){
            req.changes.add(new Change(
            1,
                new Item('$/versionControl/'+att.Name),
                new Content( EncodingUtil.base64Encode(att.Body) ,1)
            ));
        }
        system.debug(JSON.serialize(req));
        return JSON.serialize(req, true);
    }
    
    
    
    
    public class CommitReq{
          Public String comment;
        public List<Change> changes;
    }
    
    Public class Change{
      
        Public Integer changeType;
        Public  Item    item;
        Public Content newContent;
        public Change(Integer changeType,Item item,Content newContent){
           
            this.changeType=changeType;
            this.item=item;
            this.newContent=newContent;
        }
    }
    
    public class ContentMetadata{
        public Integer encoding{get;set;}
        public ContentMetadata(Integer encoding){
            this.encoding=encoding;
        }
    }
    public class Item{
        public String  path;
        public ContentMetadata  contentMetadata ;
        public Integer  version;
        public Item(String  path){
            this.path=path;
            this.contentMetadata=new ContentMetadata(65001);
        }
    }
    public class Content{
        Public String content{get;set;}
        public Integer contentType{get;set;}
        public Content(String content,Integer contentType){
            this.content=content;
            this.contentType=contentType;
        }
        
    }
}