({
	init : function(component, event, helper) {
        var action = component.get("c.getDetails");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(data) {
            var chartLabels = [];
            var chartData = [];
            var detailString = data.getReturnValue();
            console.log(detailString);
            var detailObj = JSON.parse( detailString );
            for (var key in detailObj) {
                chartLabels.push(key);
                chartData.push(detailObj[key]);
            }
            console.log('called------------------------------------------');
            
            var myCharts = component.find("deploymentInMonths").getElement();
            
          
            Chart.defaults.global.defaultFontFamily = 'Arial,sans-serif';
            Chart.defaults.global.defaultFontSize = 18;
            Chart.defaults.global.defaultFontColor = '#777';
            
            var popCharts = new Chart(myCharts,{
                type : 'line',
                data : {
                    labels : chartLabels,
                    datasets : [{
                        label : 'Deployment.',
                        data : chartData,
						backgroundColor : '#9dd9e2',
                        borderWidth : 2,
                        borderColor : '#777',
                        fill: 1
                    }],
                },
                options : {
                    title : {
                        display : true,
                        text : 'Deployments In Last 6 Months',          
                        fontSize : 20
                    },
                    legend : {
                        position : 'bottom',
                        labels : {
                            fontColor : '#000'
                        }
                    }
                }
            });
		});
        $A.enqueueAction(action);
    }
})