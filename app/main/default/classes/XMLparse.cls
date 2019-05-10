public class XMLparse {

    PRIVATE FINAL MAP <String,List<String>> DEPENDENCY = new map <String,  List<String>> {
        
        'ApexPage' => new List<String>  {'pages/{!name}.page', 'pages/{!name}.xml' }
    };

 	String ElementToRemowe ='';
    List<String> FileNamesToDelete;
    Public List <String> Files {get;set;}
    public XMLparse(String XMLString){
        Files = new List<String>();
        FileNamesToDelete = new List<String>(); 
       // XMLString = '<?xml version="1.0" encoding="UTF-8"?><Package xmlns="http://soap.sforce.com/2006/04/metadata"><types><members>TestDeploy2</members><members>TestDeploy3</members><members>TestToDeploy</members><members>TestToDeploy2</members><name>ApexPage</name></types><version>43</version></Package>';
        DOM.Document doc=new DOM.Document();
        try{
            doc.load(XMLString);
            DOM.XmlNode rootNode=doc.getRootElement();
            parseXML(rootNode);

        }catch(exception e){
            system.debug(e.getMessage());
        }
    }
    
    private void parseXML(DOM.XMLNode node) {
       
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if(node.getName()=='members'){
                FileNamesToDelete.add(node.getText().trim());
            }
            if(node.getName()=='name'){
               String pathObj =  DEPENDENCY.get(node.getText().trim())[0];
                String pathXml =  DEPENDENCY.get(node.getText().trim())[1];
                for(String str:FileNamesToDelete){
                    Files.add(pathObj.replace('{!name}', str));
                    Files.add(pathXml.replace('{!name}', str));
                }
               FileNamesToDelete = new List <String>();
            }
        }
        for (Dom.XMLNode child: node.getChildElements()) {
            parseXML(child);
        }
    }
}